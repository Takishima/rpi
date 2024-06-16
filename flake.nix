{
  description = "NixOS configuration for Raspberry Pi";
  nixConfig.bash-prompt-prefix = "❄️  ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = {flakelight, ...} @ inputs:
    flakelight ./.
    ({
      lib,
      config,
      outputs,
      ...
    }: {
      inherit inputs;
      systems = ["x86_64-linux" "aarch64-linux"];
      nixpkgs.config = {
        allowUnfree = true;
      };
      withOverlays = [
        inputs.self.overlays.octoprint
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            config = {
              allowUnfree = true;
            };
          };
        })
      ];

      formatter = pkgs: pkgs.alejandra;

      checks = {
        alejandra = pkgs: "${pkgs.alejandra}/bin/alejandra --check .";
        statix = pkgs: let
          conf = pkgs.writers.writeTOML "statix.toml" {
            ignore = ["result" ".direnv"];
          };
        in "${pkgs.statix}/bin/statix check --config ${conf}";
      };
    });

  nixConfig = {
    # NB: extra-XXX options append to the previous value instead of overriding
    auto-optimise-store = true;
    builders-use-substitutes = true;
    commit-lockfile-summary = "flake: Update inputs";
    # Keep the timeout short (Nix will do multiple attempts anyway) to avoid hanging.
    connect-timeout = 1;
    max-jobs = "auto";
    log-lines = 100; # Give more context on failure (e.g. when no --show-trace)
    # Whether to keep building derivations when another build fails.
    keep-going = true;
  };
}
# outputs = { self, nixpkgs, nixos-hardware }: rec {
#   images = {
#     pi = (self.nixosConfigurations.pi.extendModules {
#       modules = [
#         "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
#         {
#           disabledModules = [ "profiles/base.nix" ];
#         }
#       ];
#     }).config.system.build.sdImage;
#   };
#   packages.x86_64-linux.pi-image = images.pi;
#   packages.aarch64-linux.pi-image = images.pi;
#   nixosConfigurations = {
#     pi = nixpkgs.lib.nixosSystem {
#       system = "aarch64-linux";
#       modules = [
#         nixos-hardware.nixosModules.raspberry-pi-4
#         "${nixpkgs}/nixos/modules/profiles/minimal.nix"
#         ./configuration.nix
#         ./base.nix
#       ];
#     };
#   };
# };

