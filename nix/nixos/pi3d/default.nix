{
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    {
      system.stateVersion = "24.05";
    }
  ];
}
