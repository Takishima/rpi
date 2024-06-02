# Generic Raspberry Pi 4 config used to create a bootable SD card with default user
{
  system = "aarch64-linux";
  modules = [
    ./configuration.nix
    {
      system.stateVersion = "24.05";
    }
  ];
}
