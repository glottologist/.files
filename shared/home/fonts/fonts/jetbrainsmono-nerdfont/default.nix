{ lib, fetchzip, nfversion, }:
fetchzip {
  name = "jetbrainsmono-nerdfont";

  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nfversion}/JetBrainsMono.zip";
  postFetch = ''
    mkdir -p $out/share/fonts/jetbrainsmono-nerdfont
    unzip -j $downloadedFile -d $out/share/fonts/jetbrainsmono-nerdfont
  '';

  sha256 = "p6i6CTlDCGXH+puCINM69n4fLoIwBTgskbSBi7EbkJc=";

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
