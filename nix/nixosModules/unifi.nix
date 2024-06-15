{lib, config, pkgs, ...}: {
   imports = [
      "${inputs.nixpkgs}/nixos/modules/services/networking/unifi.nix"
   ];
   
   services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi8;
  }
}