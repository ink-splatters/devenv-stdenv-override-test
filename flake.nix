{
  inputs = {
    #nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv/a72055d4b3588cea2dcf08163a3be5781e838a72";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://cache.nixos.org https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  inherit (pkgs.llvmPackages_17) stdenv;
                  # https://devenv.sh/reference/options/
                  packages = [ pkgs.hello ];

                  enterShell = ''
                    export PS1="\n\[\033[01;36m\]‹non-devenv-shell› \\$ \[\033[00m\]"
                    hello
                    clang --version
                  '';

                  processes.run.exec = "hello";
                }
              ];
            };
          });
    };
}
