{
  lib,
  config,
  ...
}:
with lib; {
  options.disko = {
    device = mkOption {
      type = types.str;
      default = "/dev/mmcblk1";
      description = "Device to use when deploying the NixOS configuration";
    };

    size = {
      boot = mkOption {
        type = with types; int;
        default = 1;
        description = "Size of boot partition in Mb";
      };

      esp = mkOption {
        type = with types; int;
        default = 500;
        description = "Size of ESP partition in Mb";
      };

      swap = mkOption {
        type = with types; int;
        default = 4;
        description = "Size of swap in Gb";
      };
    };
  };

  config.disko.devices = {
    disk.main = {
      type = "disk";
      inherit (config.disko) device;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "${toString config.disko.size.boot}M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "${toString config.disko.size.esp}M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "${toString config.disko.size.swap}G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "root_vg";
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];

              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };

                "/persist" = {
                  mountOptions = ["subvol=persist" "noatime"];
                  mountpoint = "/persist";
                };

                "/nix" = {
                  mountOptions = ["subvol=nix" "noatime"];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
