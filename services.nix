{ ... }:

{
  systemd.user.services.tailscale-up = {
    Unit = {
      Description = "Start tailscale";
      Requires = "lipstick.service";
      After = "lipstick.service";
    };
    Install = {
      WantedBy = [ "post-user-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "/usr/bin/tailscale up";
    };
  };
}

