# Generic Linux AMD CPU + GPU config mainly used for testing
{
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    {
      system.stateVersion = "24.05";
    }
  ];
}
