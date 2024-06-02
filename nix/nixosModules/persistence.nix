{
  lib,
  inputs,
  config,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/etc/NetworkManager/system-connections"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      {
        file = "/var/keys/secret_file";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
  };

  programs.fuse.userAllowOther = true;

  # system.activationScripts.persistent-dirs.text = let
  #   mkHomePersist = user:
  #     lib.optionalString user.createHome ''
  #       mkdir -p /persist/${user.home}
  #       chown ${user.name}:${user.group} /persist/${user.home}
  #       chmod ${user.homeMode} /persist/${user.home}
  #     '';
  #   users = lib.attrValues config.users.users;
  # in
  #   lib.concatLines (map mkHomePersist users);
}
