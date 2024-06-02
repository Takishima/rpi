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
    ];
  })
  .config
  .system
  .build
  .sdImage
