{
  lib,
  config,
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
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
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

  # # Passwordless sudo when SSH with keys
  # security.pam.services.sudo = {config, ...}: {
  #   rules.auth.rssh = {
  #     order = config.rules.auth.ssh_agent_auth.order - 1;
  #     control = "sufficient";
  #     modulePath = "${pkgs.pam_rssh}/lib/libpam_rssh.so";
  #     settings.authorized_keys_command =
  #       pkgs.writeShellScript "get-authorized-keys"
  #       ''
  #         cat "/etc/ssh/authorized_keys.d/$1"
  #       '';
  #   };
  # };

  # # Keep SSH_AUTH_SOCK when sudo'ing
  # security.sudo.extraConfig = ''
  #   Defaults env_keep+=SSH_AUTH_SOCK
  # '';
}
