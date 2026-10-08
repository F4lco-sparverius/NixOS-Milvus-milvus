#./System-Config/configuration.nix
{pkgs, config, lib, inputs, ...}:
{
  #imports: hardware config & home-manager module & configuration for all server related services
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./server-services.nix
  ];

  #Home-Manager declaration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.zack = {
      imports = [../Home-Manager/defaults.nix];
    };
  };

  environment.systemPackages = with pkgs; [
    #gui programs
    kdePackages.dolphin
    libreoffice
    onlyoffice-desktopeditors
    firefox
    sqlitebrowser
    vlc
    kitty
    virt-manager
    krita
    proton-pass
    feishin
    telegram-desktop
    planify
    mkvtoolnix
    picard
    vscodium
    rawtherapee
    tor-browser

    #cli programs
    fastfetch
    fzf
    gitFull
    bat
    htop
    yt-dlp
    lm_sensors
    
    #dependencies
    qemu
    zip
    ly
    age sops

    #services
    tailscale
    navidrome
    jellyfin

    #tmp
    nasm
    rhash
    xxd
    mullvad-vpn
  ];

  mullvad-vpn.enable = true;

  #declaration to not install these default kde programs
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.discover
    kdePackages.konsole
  ];

  #sops configuration for assigning secrets.yaml secrets to a value 
  #(the value is expressed as a path to the secret) that can be referenced in this configuration
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/zack/.config/sops/age/keys.txt";
    secrets = {
      "lastfm_env" = {
        owner = "navidrome";
      };
    };
  };

  #vm stuff
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
      runAsRoot = false;
    };
  };

  #user declaration
  users.users.zack = {
    isNormalUser = true;
    description = "Zack";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
  };

  #network stuff
  networking.hostName = "Milvus-milvus";
  networking.networkmanager.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  #adding known hosts that use ssh for validation, these declared hosts do not neeed to be
  #manually validated or confirmed by clicking "yes i am sure" when connecting
  services.openssh.knownHosts = {
    codeberg = {
      hostNames = [ "codeberg.org" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
    };
    github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519_github
    '';
  };

  #boot stuff
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; #how long does the nixos generations selection screen appear for
  boot.kernelPackages = pkgs.linuxPackages_latest; #use the absolute latest kernel, not managed by nixpkgs

  #systemd stuff
  boot.loader.systemd-boot.enable = true;
  #disable DOB variable
  systemd.package = pkgs.systemd.override { withUserDb = false; };
  services.userdbd.enable = lib.mkForce false;

  #not sure what this does
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  #de stuff
  services.xserver.enable = false;
  services.displayManager.ly.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "gb";

  #not sure
  console.keyMap = "uk";
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #jack in msg for sudo password prompt
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults passprompt="Jack In: "
    '';
  };

  #random stuff
  nix.settings.experimental-features = ["nix-command" "flakes"]; #enable flakes
  documentation.dev.enable = false; #remove documentation for pyhton pkgs (early error fix)
  documentation.doc.enable = false; #remove documentation for pyhton pkgs (early error fix)
  system.stateVersion = "26.11"; #system state version (does nothing, is just cosmetic for things like fastfetch info)
  home-manager.backupFileExtension = "backup"; #if a non-nix file is being replaced by a nix file, add ".backup" to the end of the non-nix file and keep it rather than removing it
}
