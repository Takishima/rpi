# This config is used to customize the SD card image from NixOS
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

  environment = {
    noXlibs = lib.mkForce false;
    systemPackages = with pkgs; [
      nano
      git
    ];
  };

  users = {
    mutableUsers = false;
    users.admin = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      # NB: generated with `mkpasswd -m sha-512`
      hashedPassword = "$6$reJVMAxnLUZjjUmx$a5ZOVuIy.xLcBAmMZY8XtoHy.06RCEw94XO/c5ulDf/bSqnlY2Rlzv8U2ZVekhjxWJP5GE0xBPDEvH2KVKDjM/";
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
