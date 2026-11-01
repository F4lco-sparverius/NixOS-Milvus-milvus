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

  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers.bedrock = {
      image = "itzg/minecraft-bedrock-server";
      ports = [ "19132:19132/udp" ];
      volumes = [ "/var/lib/bedrock:/data" ];
      environment = {
        EULA = "TRUE";
        VERSION = "1.26.60";
        GAMEMODE = "survival";
        DIFFICULTY = "normal";
        ALLOW_CHEATS = "false";
        ONLINE_MODE = "true";
        DEFAULT_PLAYER_PERMISSION_LEVEL = "operator";
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/bedrock 0755 root root -" ];

  networking.firewall.interfaces."tailscale0".allowedUDPPorts = [ 19132 ];
}