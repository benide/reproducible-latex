# edited from https://flyx.org/nix-flakes-latex/

{
  description = "Reproducible LaTeX Document";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let

      # do not include ".tex"
      documentName = "document";

      pkgs = nixpkgs.legacyPackages.${system};

      # use this to get everything
      tex = pkgs.texlive.combined.scheme-full;

      # use this and add what you need for a lighter load on your nix store
      # tex = pkgs.texlive.combine {
      #   inherit (pkgs.texlive) scheme-basic latexmk;
      # };

    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "latex-demo-document";
          src = self;
          buildInputs = [ pkgs.coreutils tex pkgs.gzip pkgs.perl ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];

          # if using pdflatex instead of lualatex:
          #   1) change -lualatex to -pdflatex
          #   2) change pretex to "\pdftrailerid{}"
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              SOURCE_DATE_EPOCH=${toString self.lastModified} \
              latexmk -interaction=nonstopmode -lualatex \
              -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
              -usepretex -synctex=1 ${documentName}.tex
          '';

          installPhase = ''
            mkdir -p $out
            gzip -d ${documentName}.synctex.gz
            perl -i -pe 's|^(Input:\d+:)/build/source(.*)$|\1..\2|g' ${documentName}.synctex
            gzip ${documentName}.synctex
            cp ${documentName}.pdf $out/
            cp ${documentName}.synctex.gz $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
