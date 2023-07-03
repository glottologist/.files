{ lib, fetchzip, nfversion, }:
fetchzip {
  name = "hasklig-nerdfont";

  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nfversion}/Hasklig.zip";
  postFetch = ''
    mkdir -p $out/share/fonts/hasklig-nerdfont
    unzip -j $downloadedFile -d $out/share/fonts/hasklig-nerdfont
  '';

  sha256 = "Shtvt79mzVdrXytWNdkTUQXr5VnSbUPXAwsOp9ZqX3c=";

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
