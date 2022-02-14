{
  description = "LaTeX template for reproducible documents";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:

    # Package for imperitive installation of the same version of
    # texlive in non-NixOS systems. Use the following command:
    #   nix profile install github:benide/reproducible-latex
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

    # Overlay for fixed version of texlive
    overlay = final: prev: rec {
      texlive = nixpkgs.legacyPackages.${prev.system}.texlive;
    };

    # The template
    defaultTemplate = {
      path = ./template;
      description = "Reproducible latex document";
    };
  };
}
