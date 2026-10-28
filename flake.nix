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

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Detect current system
      system = builtins.currentSystem;

      # Import nixpkgs with config
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      # Helper to create home-manager configuration
      mkHome = username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ];
        };
    in
    {
      # homeConfigurations must be a FLAT attribute set
      # Keys are hostnames, values are home-manager configurations
      # Usage: home-manager switch --flake .#default
      #        home-manager switch --flake .#valgo@desktop
      homeConfigurations = {
        # Default: uses current user and system
        default = mkHome (builtins.getEnv "USER");

        # Host-specific configs (uncomment and customize):
        # "valgo@desktop" = mkHome "valgo";
        # "valgo@macbook" = mkHome "valgo";
      };

      # Packages output for nix build
      packages.${system} = {
        default = pkgs.hello;
        home-manager = home-manager.packages.${system}.default;
      };

      # Dev shells for development
      devShells.${system}.default = pkgs.mkShell {
        name = "dotfiles-dev";
        packages = with pkgs; [
          nixpkgs-fmt
          statix
          deadnix
          shellcheck
        ];
      };
    };
}
