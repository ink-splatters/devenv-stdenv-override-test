{
  inputs = {
    # nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv = {
      url = "github:cachix/devenv/a72055d4b3588cea2dcf08163a3be5781e838a72";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  nixConfig = {
    extra-trusted-public-keys =
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://cache.nixos.org https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          checks.default = {
            # TODO: how to make this trigger pre-commit?
            # nix flake check --impure 
          };
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [{
              inherit (pkgs.llvmPackages_17) stdenv;

              packages = [ pkgs.hello ];

              pre-commit.hooks = {
                nixfmt.enable = true;

                # markdownlint = {
                #   enable = true;
                #   settings.config = { MD013.line_length = 200; };
                # };
              };

              enterShell = ''
                echo -e '\033[01;36m'
                hello
                echo -e '...from devenv!\033[00m'
                echo
                clang --version
              '';

              processes.run.exec = "hello";
            }];
          };
        });
    };
}
