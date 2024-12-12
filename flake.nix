{
  description = "NixOS configuration for the Turing RK1";
  inputs = {
    # Stable: github:NixOS/nixpkgs/nixos-24.11
    # Unstable: github:NixOS/nixpkgs/nixos-unstable
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };

    kernel = {
      url = "git+https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git?rev=fac04efc5c793dccbd07e2d59af9f90b7fc0dca4";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            # nixpkgs.ubootTuringRK1 includes proprietary binaries from Rockchip
            "ubootTuringRK1"
          ];
      };
    in
    {
      nixosModules = {
        turing-rk1 = { ... }@args: import ./modules/turing-rk1.nix (args // { inherit inputs pkgs; });
      };

      nixosConfigurations = {
        turing-rk1 = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit pkgs inputs;
          };

          modules = [
            ./modules/turing-rk1.nix
            ./modules/os.nix
          ];
        };
      };

      packages.${system}.uboot-turing-rk1 = import ./modules/uboot-sd-image.nix {
        stdenv = pkgs.stdenv;
        inherit pkgs;
      };
    };
}
