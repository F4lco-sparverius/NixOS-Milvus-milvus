#./flake.nix
{
  description = "My flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {self, nixpkgs, sops-nix, ...} @ inputs:
  {
    nixosConfigurations.Milvus-milvus = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./System-Config/configuration.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}
