{
  description = "A flake for perl playground";
  nixConfig.bash-prompt = "[perl playground]$ $(pwd) ";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        SeleniumRemoteDriver = pkgs.perlPackages.buildPerlPackage {
          pname = "Selenium-Remote-Driver";
          version = "1.49";
          src = pkgs.fetchurl {
            url = "mirror://cpan/authors/id/T/TE/TEODESIAN/Selenium-Remote-Driver-1.49.tar.gz";
            hash = "sha256-yg7/7s6kK72vOVqI5j5EkoWKAAZAfJTRz8QY1BOX+mI=";
          };
          buildInputs = with pkgs.perlPackages; [ TestDeep TestFatal TestLWPUserAgent TestMockModule ];
          propagatedBuildInputs = with pkgs.perlPackages; [ ArchiveZip Clone FileWhich HTTPMessage IOString JSON LWP Moo SubInstall TestLongString TryTiny XMLSimple namespaceclean ];
          meta = {
            homepage = "https://github.com/teodesian/Selenium-Remote-Driver";
            description = "Perl Client for Selenium Remote Driver";
          };
        };
      in
      with pkgs; {
        devShell = mkShell {
          buildInputs = [
            chromedriver
            lsof
            pkgs.perl
            pkgs.perlPackages.DataDumper
            pkgs.perlPackages.TextCSV
            pkgs.perlPackages.Encode
            pkgs.perlPackages.JSON
            pkgs.perlPackages.LWPProtocolHttps
            pkgs.perlPackages.PerlTidy
            pkgs.perlPackages.WebScraper
            pkgs.perlPackages.HTMLTokeParserSimple
            SeleniumRemoteDriver
          ];
          # LWP was throwing a warning about multiple shell vars
          # so shut it up like so:
          shellHook = ''
            export SHELL=/usr/env/bash
            unset shell
            printf "Welcome to Perl Playground!\n"
          '';
        };
      });
}
