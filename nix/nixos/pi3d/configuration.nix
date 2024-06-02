{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;
in {
  imports = [
    {
      system.activationScripts = {
        persistent-dirs-system.text = "mkdir -p /persist/system";
      };
    }
    "${inputs.nixpkgs}/nixos/modules/profiles/headless.nix"
    inputs.disko.nixosModules.default
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    self.nixosModules.boot
    self.nixosModules.disko
    self.nixosModules.nix
    self.nixosModules.octoprint
    self.nixosModules.openssh
    self.nixosModules.persistence
    self.nixosModules.sops
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
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

    # Use the extlinux boot loader
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  disko.device = "/dev/mmcblk0";

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
    users.damien = {
      hashedPasswordFile = config.sops.secrets."users/damien".path;
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };

  time.timeZone = "Europe/Amsterdam";
  services.xserver.xkb = {
    layout = "ch";
    variant = "de,";
  };
  console.useXkbConfig = true;

  sops = {
    defaultSopsFile = ./secrets.yml;
    secrets = {
      "users/damien" = {
        neededForUsers = true;
      };
      wifi-env = {};
    };
  };

  networking = {
    hostName = "pi3d";
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = ["wlan0"];
      environmentFile = config.sops.secrets."wifi-env".path;
      networks = {
        "@wifi_ssid@" = {
          psk = "@wifi_psk@";
        };
      };
    };
  };
}
