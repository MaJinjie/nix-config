#!/usr/bin/env bash

set -eu

export USERNAME=majinjie
export MOUNT_SSH_SUBDIR=.ssh
export MOUNT_SSH_POINT=/mnt/ssh

# ===================================== utils =================================={{{

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BOLD='\033[1m'
DIM='\033[2m'
CLEAR='\033[0m'

_print() {
  printf "${1-}" "${@:2}"
}

_info() {
  _print "${BLUE}${1}${CLEAR}\n" "${@:2}"
}

_warn() {
  _print "${YELLOW}${1}${CLEAR}\n" "${@:2}"
  return 1
}

_error() {
  _print "${RED}${1}${CLEAR}\n" "${@:2}"
  exit 1
}

_hint() {
  _print "${CYAN}${1}${CLEAR}\n" "${@:2}"
}

_prompt() {
  _print "${MEGENTA}${1}${CLEAR}"
  read -r "${2}"
}

_confirm() {
  _print "${DIM}${WHITE}${1}${CLEAR}"
  read -r && case "${REPLY}" in
    [Yy] | 1 | [Yy][Ee][Ss])  true ;;
    [Nn] | 0 | [Nn][Oo])  false ;;
    *) _error "\nInvalid option. Exiting script." ;;
  esac
}

# }}}===================================== utils ==================================

check_env() {
  if [ -e /etc/NIXOS ]; then
    _info "Running in the NixOS installer environment."
  else
    _error "Not running in the NixOS installer environment."
  fi

  if [ "$(id -u)" -ne 0 ]; then
    _error "The current user is not root."
  fi
}

download_config() {
  curl -LJO https://github.com/majinjie/nix-config/archive/main.zip
  unzip nix-config-main.zip
  mv nix-config-main nix-config
  cd nix-config
}

cleanup_config() {
  rm -rf nix-config-main.zip nix-config
}

# ===================================== ssh =================================={{{

check_ssh_keys() {
  if [ -f /root/.ssh/id_ed25519 ] && [ -f /root/.ssh/id_ed25519.pub ]; then
    _info "All SSH keys are present."
  else
    _warn "Some SSH keys are missing."
    if [ ! -f /root/.ssh/id_ed25519 ]; then
      _error "Missing: id_ed25519."
    fi
    if [ ! -f /root/.ssh/id_ed25519.pub ]; then
      _warn "Missing: id_ed25519.pub."
    fi
  fi
}

copy_ssh_keys() {
  DRIVER_NAME="${MOUNT_SSH_POINT##*/}" DRIVER_NAME="${DRIVER_NAME,,}"

  if mountpoint -q $MOUNT_SSH_POINT; then
    _info "$DRIVER_NAME driver already mounted."
  else
    local device

    _info "$DRIVER_NAME driver not mounted!"
    if lsblk && _prompt "Please select device to mount: " device; then
      if mount --mkdir /dev/$device $MOUNT_SSH_POINT; then
        _info "$DRIVER_NAME drive mounted successfully on /dev/$device."
      else
        _error "Failed to mount /dev/$device"
      fi
    else
      _warn "No device selected."
    fi

    if [[ $? -eq 0 ]]; then
      if [[ ! -f /root/.ssh/id_ed25519 ]]; then
        cp $MOUNT_SSH_POINT/$MOUNT_SSH_SUBDIR/id_ed25519 /root/.ssh
        chmod 600 /root/.ssh/id_ed25519
      fi
      if  [[ ! -f /root/.ssh/id_ed25519.pub && -f $MOUNT_SSH_POINT/$MOUNT_SSH_SUBDIR/id_ed25519.pub ]]; then
        cp $MOUNT_SSH_POINT/$MOUNT_SSH_SUBDIR/id_ed25519.pub /root/.ssh
        chmod 600 /root/.ssh/id_ed25519.pub
      fi
      umount $MOUNT_SSH_POINT
    fi
  fi
}

create_ssh_keys() {
  ssh-keygen -t ed25519 -f "/root/.ssh/id_ed25519" -N ""
  chmod 600 ${SSH_DIR}/id_ed25519{,.pub}

  _info "New SSH keys have been generated."
  _hint "1) Add the id_ed25519.pub key to Github."
  cat /root/.ssh/id_ed25519_github.pub
  _hint "2) Create a private nix-secrets repo in Github, even if it's empty."
}

setup_ssh() {
  _confirm "Do you want to Processing Key? " || return

  [ -d /root/.ssh ] || mkdir -p /root/.ssh

  check_ssh_keys && return
  if _confirm "Do you need to copy keys? "; then
    copy_ssh_keys
  fi 

  check_ssh_keys && return
  if _confirm "Do you need to create keys? "; then
    create_ssh_keys
  fi 
  check_ssh_keys || _error "No SSH keys found."

  ssh-keyscan -t ed25519 github.com >> /root/.ssh/known_hosts
}

# }}}===================================== ssh ==================================

run_disko() {
  _confirm "Do you want to use disko for disk partitioning? " || return

  nix run --extra-experimental-features "nix-command flakes" \
    github:nix-community/disko -- --mode destroy,format,mount ./modules/nixos/disko.nix
}

setup_nixos() {
  mkdir -p /mnt/home/${USERNAME}/.ssh
  cp /root/.ssh/* /mnt/home/${USERNAME}/.ssh

  ln -s /mnt/home/${USERNAME} /home/${USERNAME} # Used to grab initial secrets

  mkdir -p /mnt/etc/nixos
  cp -r * /mnt/etc/nixos
  cd /mnt/etc/nixos
}

install_nixos() {
  ARCH=$(uname -m)

  case "$ARCH" in
    x86_64)
      FLAKE_TARGET="x86_64-linux"
      ;;
    aarch64)
      FLAKE_TARGET="aarch64-linux"
      ;;
    *)
      _error "Unsupported architecture: $ARCH"
      ;;
  esac

  nixos-install --flake .#$FLAKE_TARGET "$@"

  chmod -R :wheel /mnt/etc/nixos
  chmod -R 775 /mnt/etc/nixos
}

prompt_reboot() {
  if _confirm "Do you want to reboot now? "; then
    _info "Rebooting..." 
    reboot
  else
    _info "Reboot skipped."
  fi
}

check_env
download_config
setup_ssh
run_disko
setup_nixos
install_nixos
cleanup_config
prompt_reboot
