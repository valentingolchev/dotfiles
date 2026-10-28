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
      # Helper to create pkgs for a system
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      # Helper to create home-manager configuration
      mkHome = system: username:
        let
          pkgs = mkPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username; };
          modules = [ ./home.nix ];
        };
    in
    {
      # homeConfigurations must be a FLAT attribute set
      # Keys are "username@hostname", values are home-manager configurations
      # Usage: home-manager switch --flake .#valgo@desktop
      homeConfigurations = {
        # TODO: Update these with your actual hostnames
        "valgo@desktop" = mkHome "x86_64-linux" "valgo";
        "valgo@laptop" = mkHome "x86_64-linux" "valgo";
        "valgo@macbook" = mkHome "aarch64-darwin" "valgo";
      };

      # Packages output for nix build
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system: {
        default = (mkPkgs system).hello;
        home-manager = home-manager.packages.${system}.default;
      });

      # Dev shells for development
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            name = "dotfiles-dev";
            packages = with pkgs; [
              nixpkgs-fmt
              statix
              deadnix
              shellcheck
            ];
          };
        }
      );
    };
}
