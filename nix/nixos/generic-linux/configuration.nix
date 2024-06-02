{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (inputs) self;
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/graphical.nix"
    inputs.disko.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    self.nixosModules.boot
    self.nixosModules.disko
    self.nixosModules.nix
    self.nixosModules.openssh
    self.nixosModules.persistence
    self.nixosModules.sops
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  disko.device = "/dev/nvme0n1";

  environment = {
    noXlibs = lib.mkForce false;
    systemPackages = with pkgs; [
      nano
      git
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
    age.sshKeyPaths = map getKeyPath keys;
    secrets = {
      "users/damien" = {
        neededForUsers = true;
      };
      wifi-env = {};
    };
  };

  networking = {
    hostName = "generic";
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
