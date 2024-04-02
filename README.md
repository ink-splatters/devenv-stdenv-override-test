# devenv-test

small project to test `devenv`'s [stdenv override](https://github.com/cachix/devenv/commit/a72055d4b3588cea2dcf08163a3be5781e838a72) support

## Prerequisites

`nix` with `flakes` and `nix-command` experimental features enabled

## Quick Start

```sh
direnv allow . # optionally
nix develop --impure
```

## Found Issues

NOTE: Not all issues might be related to the change being tested

### binary cache issue with devenv flake template

project was created with:

``sh
nix flake init --template github:cachix/devenv
``

notably, with `nixpkgs` input set to:

```nix
{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    ...

```

#### The issue

given `stdenv` is overriden to: `llvmPackages_17.stdenv`, `llvm` is being built from sources

#### (Temporary) mitigation

```nix
inputs = {
    # nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    ...
```

(see source code)

### devenv up minor issue

`devenv up` briefly shows beautiful TUI before crashing with the following:

```sh
(devenv) airstation:devenv-test ic$ devenv up
{"level":"warn","error":"open /Users/ic/Library/Application Support/process-compose/settings.yaml: no such file or directory","time":"2024-04-02T10:23:49+02:00","message":"Error reading settings file /Users/ic/Library/Application Support/process-compose/settings.yaml"}
```

I didn't check if creating the file would help. However, I created empty directory - it didn't help

### nixfmt pre-commit hook cannot find *.nix files

#### The issue

the following:

```nix
 pre-commit.hooks = {
                nixfmt.enable = true;
                ...
```

alone, says: "no files to check":

```sh
airstation:devenv-test ic$ nxd --impure

...

pre-commit-hooks.nix: updating /Users/ic/dev/devenv-test repo
pre-commit installed at .git/hooks/pre-commit

Hello, world!
...from devenv!

clang version 17.0.6
Target: arm64-apple-darwin
Thread model: posix
InstalledDir: /nix/store/ij7x28my4zhjfh59c286k9h1kxyz3ipk-clang-17.0.6/bin
(devenv) airstation:devenv-test ic$ gc -a
nixfmt...............................................(no files to check)Skipped
```

however, adding:

```nix
languages.nix.enable = true;
```

makes things work

#### Expected behavior

pre-commit hook: `nixfmt` has been installed. that is, IMO I don't need to enable language servers (which come as part of languages.nix) to

be able to format *.nix files

## Credits

@domenkozar - for devenv!
