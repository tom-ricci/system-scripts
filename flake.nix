{
  description = "NixOS system management utility";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          script-id = "system";
          deps = with pkgs; [ bashInteractive git coreutils gnugrep sudo nix nixos-rebuild dconf gawk ];
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