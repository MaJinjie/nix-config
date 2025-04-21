{ user, agenix, pkgs, config, ... }: 

{
  # nix settings
  nix = {
    nixPath = ["nixos-config=/etc/nixos"];
    settings = {
      allowed-users = ["${user}"];
      trusted-users = ["${user}"];
      substituters = [ 
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://nix-community.cachix.org" 
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
  };

  # timeZone
  time.timeZone = "Asia/Shanghai";

  # network
  networking = {
    hostName = "nixos"; # Define your hostname.
    useDHCP = false;
    interfaces."wlp8s0".useDHCP = true;
  };

  # internationalization
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "zh_CN.UTF-8/UTF-8"]; # 支持的语言环境
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-rime
          fcitx5-chinese-addons
        ];
      };
    };
  };

  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  # services
  services.pipewire = {
    enable = true;
  };
  services.libinput.enable = true;

  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" ];
    passwordFile = config.age.secrets."login-passwd.age";
  };

  # fonts
  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = ["Fira Code Nerd Font"];
        sansSerif = ["Noto Sans" "Noto Sans CJK SC"];
        serif = ["Noto Serif" "Noto Serif CJK SC"];
        emoji = ["Noto Color Emoji"];
      };
      # Becase of Noto Color Emoji doesn't render on Firefox.
      useEmbeddedBitmaps = true;
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      nerd-fonts.fira-code
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget curl
    git 
    gcc gnumake cmake

    wl-clipboard

    fd ripgrep-all
    yazi

    agenix
  ];

  system.stateVersion = "24.11";
}
