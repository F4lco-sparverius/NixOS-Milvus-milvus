#./Home-Manager/Shells/c-sharp.nix
{pkgs, lib, config, ...}:
{
  home.file."Documents/Programming/Shells/CSharp/shell.nix" = {
    text = ''
      {pkgs ? import <nixpkgs> {}}:

      pkgs.mkShell {
        name = "csharp-dev";

        nativeBuildInputs = with pkgs; [
          dotnet-sdk
          omnisharp-roslyn
          netcoredbg
          pkg-config
        ];

        buildInputs = with pkgs; [
          openssl
        ];
        shellHook = '''
          export TMPDIR=/tmp
        ''';
      }
    '';
  };
}