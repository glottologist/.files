{pkgs, ...}: {
 nixpkgs.overlays = [
    (self: super: {
      gfortran-wrapper = super.gfortran-wrapper.overrideAttrs (oldAttrs: {
        # Remove the cpp binary from this package
        postInstall = ''
          ${oldAttrs.postInstall or ""}
          rm -f $out/bin/cpp
        '';
      });
    })
  ];
  home.packages = with pkgs; [
    gfortran
    fortran-fpm
    fortran-language-server
  ];
}
