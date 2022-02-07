{
  description = "LaTeX template for reproducible documents";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:

    # Package for installing the same version of texlive in non-NixOS systems:
    # e.g., using: nix profile install github:benide/reproducible-latex
    with flake-utils.lib; eachSystem defaultSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};

      # use this to get everything
      tex = pkgs.texlive.combined.scheme-full;

      # use this for more limited scope
      # tex = pkgs.texlive.combine {
      #   inherit (pkgs.texlive) scheme-basic latexmk;
      # };

    in rec {
      defaultPackage = tex;
    }) // {

    # Module for installing the same version of texlive in NixOS config flakes
    nixosModule = { config, pkgs, ... }: {
      config.environment.systemPackages = [
        nixpkgs.legacyPackages."x86_64-linux".texlive.combined.scheme-full
      ];
    };

    # The template
    defaultTemplate = {
      path = ./template;
      description = "Reproducible latex document";
    };
  };
}
