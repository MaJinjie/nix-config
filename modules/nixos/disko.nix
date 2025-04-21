_: 

{
disko.devices = {
  disk = {
    main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          NIXOS = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"]; # Override existing partition
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                };
                "@home" = {
                  mountOptions = ["compress=zstd"];
                  mountpoint = "/home";
                };
                "@nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
                "@snap" = {
                  mountOptions = ["compress=zstd"];
                  mountpoint = "/snap";
                };
                "@swap" = {
                  mountpoint = "/.swapvol";
                  swap = {
                    swapfile1.size = "8G";
                    swapfile2.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
};
}
