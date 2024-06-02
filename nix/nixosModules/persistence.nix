{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/ssh"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  programs.fuse.userAllowOther = true;

  system.activationScripts = {
    persistentDirsSystem.text = "mkdir -p /persist/system";
    persistentDirsHomes.text = let
      mkHomePersist = user:
        lib.optionalString user.createHome ''
                mkdir -p /persist/${user.home}
          #       chown ${user.name}:${user.group} /persist/${user.home}
          #       chmod ${user.homeMode} /persist/${user.home}
          #     '';
      users = lib.attrValues config.users.users;
    in
      lib.concatLines (map mkHomePersist users);

    # Make sure that our setup scripts run *before* these others
    users.deps = ["persistentDirsSystem" "persistentDirsHomes"];
    setupSecretsForUsers.deps = ["persistentDirsSystem" "persistentDirsHomes"];
  };
}
