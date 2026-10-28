{
  description = "Dotfiles with home-manager for package management";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

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
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
          };
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ];
        };
    in
    {
      # Usage: home-manager switch --flake .#default
      # Or for specific hosts: home-manager switch --flake .#username@hostname
      homeConfigurations = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Default: uses current user (fallback)
          default = mkHome system (builtins.getEnv "USER");

          # Example host-specific configs (uncomment and customize):
          # "valgo@desktop" = mkHome "x86_64-linux" "valgo";
          # "valgo@macbook" = mkHome "aarch64-darwin" "valgo";
        }
      );
    };
}
