{
  description = "A flake for perl playground";
  nixConfig.bash-prompt = "[perl playground]$ $(pwd) ";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in with pkgs; {
        devShell = mkShell {
          buildInputs = [
            pkgs.perl
            pkgs.perlPackages.LWPProtocolHttps
            pkgs.perlPackages.HTMLTokeParserSimple
            pkgs.perlPackages.JSON
            pkgs.perlPackages.Encode
          ];
          shellHook = ''
            printf "Welcome to Perl Playground!\n"
          '';
        };
      });
}
