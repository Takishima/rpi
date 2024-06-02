# This config is used to customize the SD card image from NixOS
#
# Update RPi firmware:
# > mount /dev/disk/by-label/FIRMWARE /mnt
# > BOOTFS=/mnt FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-update -d -a
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;
  secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
in {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    {
      disabledModules = ["profiles/base.nix"];
    }
    self.nixosModules.boot
    self.nixosModules.nix
  ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    # Workaround these kinds of errors:
    #   kexec_file_load failed: Resource busy
    #   kexec_file_load failed: Resource busy
    # cf. https://www.thegoodpenguin.co.uk/blog/booting-linux-from-linux-with-kexec/
    kernelParams = ["nr_cpus=1"];
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

    # Use the extlinux boot loader
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  environment = {
    noXlibs = lib.mkForce false;
    systemPackages = with pkgs; [
      curl
      git
      libraspberrypi
      nano
      nix
      raspberrypi-eeprom
      wget
    ];
  };

  users = {
    mutableUsers = false;
    groups = {
      nixos = {
        gid = 1000;
        name = "nixos";
      };
    };
    users = {
      nixos = {
        uid = 1000;
        home = "/home/nixos";
        name = "nixos";
        group = "nixos";
        # NB: generated with `mkpasswd -m sha-512`
        hashedPassword = "$6$reJVMAxnLUZjjUmx$a5ZOVuIy.xLcBAmMZY8XtoHy.06RCEw94XO/c5ulDf/bSqnlY2Rlzv8U2ZVekhjxWJP5GE0xBPDEvH2KVKDjM/";
        isNormalUser = true;
        extraGroups = ["wheel"];
      };
      root = {
        # NB: generated with `mkpasswd -m sha-512`
        hashedPassword = "$6$reJVMAxnLUZjjUmx$a5ZOVuIy.xLcBAmMZY8XtoHy.06RCEw94XO/c5ulDf/bSqnlY2Rlzv8U2ZVekhjxWJP5GE0xBPDEvH2KVKDjM/";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGmC1fWtJth5ntDBSwGnVudA+3wjCi94dsprtpw4v5Wn"
        ];
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = ["admin"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  time.timeZone = "Europe/Amsterdam";

  services.xserver.xkb = {
    layout = "ch";
    variant = "de,";
  };
  console.useXkbConfig = true;

  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = true; # TODO: Change this to false
      PermitRootLogin = "yes";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts = {
      generic-pi = {
        publicKeyFile = ./ssh_host_ed25519_key.pub;
        extraHostNames = ["localhost"];
      };
    };
  };

  networking = {
    hostName = "generic-pi";
    interfaces."wlan0".useDHCP = true;

    wireless = {
      userControlled.enable = true;
      interfaces = ["wlan0"];
      enable = true;

      networks = secrets.wifi-networks;
    };
  };
}
