{ pkgs, config, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      useOsProber = false;
      default = "saved";
      device = "nodev";
      extraEntries = ''
        ${
          if config.boot.loader.grub.useOSProber then
            ''
              menuentry "Windows" {
                search --file --no-floppy --set=root /EFI/Microsoft/Boot/bootmgfw.efi
                chainloader (''${root})/EFI/Microsoft/Boot/bootmgfw.efi
              }
            ''
          else
            ""
        }
        menuentry "System shutdown" {
          echo "System shuting down..."
          halt
        }
        menuentry "System reboot" {
          echo "System rebooting..."
          reboot
        }
        menuentry 'UEFI Firmware Settings' --id 'uefi-firmware' {
          fwsetup
        }
      '';
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "lenovo";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  
  fonts = {
    fontconfig.defaultFonts = {
      monospace = [ 
        "JetBrains Mono Nerd Font"
        "Fira Code Nerd Font" 
        "Hack Nerd Font"
      ];
      sansSerif = [ "Noto Sans CJK SC" ];
      serif = [ "Noto Serif CJK SC" ];
      emoji = [ "Noto Color Emoji" ];
    };
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      maple-mono.NF-CN
    ];
  };
}