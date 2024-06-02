{inputs}: let
  inherit (inputs) self;
in
  (self.nixosConfigurations.generic-pi.extendModules {
    modules = [
      ({
        config,
        lib,
        ...
      }: {nixpkgs.buildPlatform = lib.mkDefault "x86_64-linux";})
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
      {
        disabledModules = ["profiles/base.nix"];
      }
    ];
  })
  .config
  .system
  .build
  .isoImage
