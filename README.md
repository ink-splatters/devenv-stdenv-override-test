# devenv-test

small project to test `devenv` [stdenv override](https://github.com/cachix/devenv/commit/a72055d4b3588cea2dcf08163a3be5781e838a72) support

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

``shell
nix flake init --template github:cachix/devenv
``

notably, with `nixpkgs` input set to:


```sh
{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    ...

```

#### The issue

given `stdenv` is overriden to: `llvmPackages_17.stdenv`, `llvm` is being built from sources


#### Expected behavior

`llvm` is not built from source, but taken from binary cache


### (Temporary) mitigation

```sh
inputs = {
    # nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    ...
```

(see source code)


### devenv up minor issue

#### The issue

`devenv up` briefly shows beautiful TUI before crashing with the following:

```sh
(devenv) airstation:devenv-test ic$ devenv up
{"level":"warn","error":"open /Users/ic/Library/Application Support/process-compose/settings.yaml: no such file or directory","time":"2024-04-02T10:23:49+02:00","message":"Error reading settings file /Users/ic/Library/Application Support/process-compose/settings.yaml"}
```

I didn't check if creating the file would help. However, I created empty directory - it didn't help

#### Expected behavior

`devenv up` works smoothly


## Credits

@domenkozar - for devenv!


