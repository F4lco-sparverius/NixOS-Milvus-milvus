#./System-Config/server-services.nix
{pkgs, config, lib, inputs, ...}:
{
  #navidrome configuration available on nixos
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      MusicFolder = "/srv/music";
      Address = "0.0.0.0";
      Port = 4533;
      DataFolder = "/var/lib/navidrome";
      ScannerEnabled = false;
      LogLevel = "info";
      LastFM.Enabled = true;
      Tags.Artists.Split = [" / " " feat. " " feat " " ft. " " ft " "/ " "; " " & " " , " ", " "," "/" "&" "  "];
    };
  };
  
  #getting lastfm secrets from sops and setting them in navidrome env file
  systemd.services.navidrome.serviceConfig.EnvironmentFile =
    config.sops.secrets."lastfm_env".path;
  
  #navidrome playlist track duplication prevention service
  systemd.services.navidrome-dedup-trigger = {
    description = "Install duplicate-prevention trigger in Navidrome DB";

    after = ["navidrome.service"];
    requires = [ "navidrome.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "navidrome";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
    };

    script = ''
      until ${pkgs.sqlite}/bin/sqlite3 \
          /var/lib/navidrome/navidrome.db \
          ".tables" 2>/dev/null \
        | grep -q "playlist_tracks"
      do
        sleep 1
      done

      ${pkgs.sqlite}/bin/sqlite3 /var/lib/navidrome/navidrome.db "
        CREATE TRIGGER IF NOT EXISTS prevent_duplicate_playlist_tracks
        BEFORE INSERT ON playlist_tracks
        FOR EACH ROW
        WHEN EXISTS (
          SELECT 1 FROM playlist_tracks
          WHERE playlist_id    = NEW.playlist_id
          AND   media_file_id  = NEW.media_file_id
        )
        BEGIN
          SELECT RAISE(IGNORE);
        END;
      "

      echo "Trigger installed successfully"

      ${pkgs.sqlite}/bin/sqlite3 /var/lib/navidrome/navidrome.db \
        "UPDATE playlist SET sync = 0 WHERE sync = 1;"
    '';
  };

  #jellyfin configuration
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
    dataDir = "/var/lib/jellyfin";
    configDir = "/etc/jellyfin";
    cacheDir = "/var/cache/jellyfin";
    logDir = "/var/log/jellyfin";
  };

  #enable tailscale for non-lan access
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # BDS is proprietary but free to download/run
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "bedrock-server" ];

  users.users.bedrock = {
    isSystemUser = true;
    group = "bedrock";
    home = "/var/lib/bedrock";
  };
  users.groups.bedrock = {};

  # Lets you send console commands to the server (see below)
  systemd.sockets.bedrock = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenFIFO = "/run/bedrock.stdin";
      SocketUser = "bedrock";
      SocketMode = "0660";
      RemoveOnStop = true;
      FlushPending = true;
    };
  };

  systemd.services.bedrock = {
    description = "Minecraft Bedrock Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "bedrock.socket" ];

    preStart = ''
      cat > server.properties <<EOF
      server-name=Home Server
      gamemode=survival
      difficulty=normal
      allow-cheats=false
      online-mode=true
      allow-list=false
      default-player-permission-level=operator
      level-name=world
      server-port=19132
      EOF
    '';

    serviceConfig = {
      ExecStart = "${pkgs.bedrock-server}/bin/bedrock_server";
      WorkingDirectory = "/var/lib/bedrock";
      StateDirectory = "bedrock";
      User = "bedrock";
      Group = "bedrock";
      Restart = "always";
      StandardInput = "socket";
      StandardOutput = "journal";
      Environment = "LD_LIBRARY_PATH=.";
    };
  };

  networking.firewall.allowedUDPPorts = [ 19132 ];
}