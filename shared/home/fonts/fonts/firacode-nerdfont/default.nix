{ lib, fetchzip, nfversion }:
fetchzip {
  name = "firacode-nerdfont";

  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nfversion}/Firacode.zip";

  postFetch = ''
    mkdir -p $out/share/fonts/firacode-nerdfont
    unzip -j $downloadedFile -d $out/share/fonts/firacode-nerdfont
  '';

  sha256 = "AKjJ/KN+hBpoIXCo3KlRk1EHOZN2Bqc1g036zLdXLrs=";

  meta = with lib; {
    description = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
