{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name = "perl-playground";
  buildInputs = [
    pkgs.perl # important!
    pkgs.perlPackages.LWP
    pkgs.perlPackages.LWPProtocolhttps
    pkgs.perlPackages.PerlTidy
  ];
}
