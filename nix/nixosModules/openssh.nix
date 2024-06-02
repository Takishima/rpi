{
  lib,
  config,
  pkgs,
  ...
}: let
  hosts = ["pi3d"];
in {
  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = true; # TODO: Change this to false
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };

    hostKeys = [
      # Important: all keys need to be in /persist/system/
      {
        path = "/persist/system/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts = lib.genAttrs hosts (hostname: {
      publicKeyFile = ../nixos/${hostname}/ssh_host_ed25519_key.pub;
      extraHostNames = ["localhost"];
    });
  };

  # Passwordless sudo when SSH with keys
  security.pam.services.sudo = {config, ...}: {
    rules.auth.rssh = {
      order = config.rules.auth.ssh_agent_auth.order - 1;
      control = "sufficient";
      modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
      settings.authorized_keys_command =
        pkgs.writeShellScript "get-authorized-keys"
        ''
          cat "/etc/ssh/authorized_keys.d/$1"
        '';
    };
  };

  # Keep SSH_AUTH_SOCK when sudo'ing
  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  system.activationScripts = {
    generateSshHostKeys = {
      # The tricky part here is that we are actually going to run *before* the users are created,
      # since sops-nix needs to setup the secrets to be abilable then. At this point in time the
      # root user does not exist fully, so calling ssh-keygen is out of the question
      #
      # The code below assumes that the SSH host keys can be found at /etc/ssh/...
      # If installing using nixos-anywhere, you will need to pass --extra-files <dir> and make sure
      # that <dir>/etc/ssh is populated.
      text = let
        generateKey = key: ''
           if ! [ -s "${key.path}" ]; then
              if ! [ -h "${key.path}" ]; then
                  rm -f "${key.path}"
              fi

              mkdir -v -m 0755 -p "$(dirname '${key.path}')"

              key_path="${key.path}"
              key_path="''${key_path///persist\/system}"

              echo "Copying SSH host key from $key_path to ${key.path}"
              cp -v "$key_path"* "$(dirname '${key.path}')"
          fi'';
      in
        lib.concatLines (map generateKey config.services.openssh.hostKeys);
      deps = ["specialfs" "persistentDirsSystem"];
    };
    setupSecretsForUsers.deps = ["generateSshHostKeys"];
  };
}
