{
  description = "NixOS system management utility";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/cdd2ef009676ac92b715ff26630164bb88fec4e0"; # most recent commit in the nixos-24.11 channel at unix timestamp 1742121143
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b"; # most recent commit in the repo at unix timestamp 1742121143
  };
  outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          script-id = "system";
          deps = with pkgs; [ bashInteractive git coreutils gnugrep nix nixos-rebuild dconf gawk ];
          script = (pkgs.writeScriptBin script-id (builtins.readFile ./src/script.sh)).overrideAttrs(old: {
            buildCommand = "${old.buildCommand}\n patchShebangs $out";
          });
        in rec {
          defaultPackage = packages.system-scripts;
          packages.system-scripts = pkgs.symlinkJoin {
            name = script-id;
            paths = [ script ] ++ deps;
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = "wrapProgram $out/bin/${script-id} --prefix PATH : $out/bin";
          };
        }
      );
}