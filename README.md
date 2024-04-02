# devenv: overriding stdenv support (test)

small project to test `devenv`'s [stdenv override](https://github.com/cachix/devenv/commit/a72055d4b3588cea2dcf08163a3be5781e838a72) support

## Prerequisites

`nix` with `flakes` and `nix-command` experimental features enabled

## Quick Start

```sh
nix develop github:ink-splatters/devenv-stdenv-override-test --impure --accept-flake-config
```

or, for development: 

```sh
git clone https://github.com/ink-splatters/devenv-stdenv-override-test.git && devenv-stdenv-override-test
direnv allow . # optionally
nix develop --impure --accept-flake-config
```

## Found Issues

**NOTE**: Not all issues might be related to the change being tested

### 1. Binary cache issue with devenv flake template

#### Preconditions

flake project created with:

```sh
nix flake init --template github:cachix/devenv
```
#### The issue

given `stdenv` is overriden to: `llvmPackages_17.stdenv`, `llvm` is being built from sources

notably, `nixpkgs` is set to:

```nix
{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    ...
```

#### (Temporary) mitigation

```nix
inputs = {
    # nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    ...
```

(see source code)

### 2. Minor issue with `devenv up`

`devenv up` briefly shows beautiful TUI before crashing with the following:

```sh
(devenv) airstation:devenv-test ic$ devenv up
{"level":"warn","error":"open /Users/ic/Library/Application Support/process-compose/settings.yaml: no such file or directory","time":"2024-04-02T10:23:49+02:00","message":"Error reading settings file /Users/ic/Library/Application Support/process-compose/settings.yaml"}
```

**NOTE**: I didn't check if creating the file would help. However, I created empty directory - it didn't help

### 3. `languages.nix.enable = true` is required for `nixfmt` pre-commit hook to work

#### Prerequisites

```nix
...
 pre-commit.hooks.nixfmt.enable = true;
 languages.nix.enable = false;
...
```

#### The issue

```sh
airstation:devenv-test ic$ nix develop --impure --accept-flake-config

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

mind the last line: **`...(no files to check)Skipped`**

**However:** adding:

```nix
languages.nix.enable = true;
```

makes everything work.

#### Expected behavior

The combination:
```nix
...
 pre-commit.hooks.nixfmt.enable = true;
 languages.nix.enable = false;
...
```
works.


#### Motivation

IMO one may not need LSPs which come with enabling a language, e.g. if they just need formatting functionality.

## Credits

[@domenkozar](https://github.com/domenkozar) for:
- cachix
- devenv

