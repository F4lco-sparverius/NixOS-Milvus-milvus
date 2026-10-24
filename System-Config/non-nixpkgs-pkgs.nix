#non-nixpkgs-pkgs.nix
{pkgs}:
{
  wordcraft = pkgs.stdenv.mkDerivation rec {
    pname = "wordcraft";
    version = "0.8.0";
    src = pkgs.fetchurl {
      url = "https://github.com/storytold/wordcraft/releases/download/v0.8.0/wordcraft-0.8.0-linux-x86_64.tar.gz";
      hash = "sha256-Ds4Hzz2RuSPf2A+QMQ4EmDveZvAnnGtg3c6JWW3eDd8=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    runtimeDependencies = with pkgs; [
      wayland
      libglvnd
      vulkan-loader
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxrandr
    ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      runHook postInstall
    '';
  };

  deckcraft = pkgs.stdenv.mkDerivation rec {
    pname = "deckcraft";
    version = "0.9.0";
    src = pkgs.fetchurl {
      url = "https://github.com/storytold/deckcraft/releases/download/v0.9.0/deckcraft-0.9.0-linux-x86_64.tar.gz";
      hash = "sha256-UxtMjNQ0ynZ+8h2g1E4JlmSvXV2WiwOLyPkncX+PqPE=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.alsa-lib
    ];
    runtimeDependencies = with pkgs; [
      wayland
      libglvnd
      vulkan-loader
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxrandr
    ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      runHook postInstall
    '';
  };

  lightcraft = pkgs.stdenv.mkDerivation rec {
    pname = "lightcraft";
    version = "0.13.0";
    src = pkgs.fetchurl {
      url = "https://github.com/storytold/lightcraft/releases/download/v0.13.0/lightcraft-0.13.0-linux-x86_64.tar.gz";
      hash = "sha256-hzx5XmQeqMNF4C5IlfbCZZAV5TFCD2g1LKNCGqm47c0=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    runtimeDependencies = with pkgs; [
      wayland
      libglvnd
      vulkan-loader
      libxkbcommon
      libx11
      libxcursor
      libxi
      libxrandr
    ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      runHook postInstall
    '';
  };
}