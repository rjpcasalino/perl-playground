{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name = "bss";
  buildInputs = [
    pkgs.perl # important!
    pkgs.perlPackages.LWP
    pkgs.perlPackages.LWPProtocolhttps
    pkgs.perlPackages.PerlTidy
  ];
}
