{
  description = "Dotfiles with home-manager for package management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Helper to create home-manager configuration
      mkHome = system: username:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ];
        };
    in
    {
      # Usage: home-manager switch --flake .#username@hostname
      # Or: home-manager switch --flake .#default (uses current user)
      homeConfigurations = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = mkHome system (builtins.getEnv "USER");
        }
      );

      # For specific hosts, add them like this:
      # homeConfigurations."valgo@desktop" = mkHome "x86_64-linux" "valgo";
      # homeConfigurations."valgo@macbook" = mkHome "aarch64-darwin" "valgo";
    };
}
