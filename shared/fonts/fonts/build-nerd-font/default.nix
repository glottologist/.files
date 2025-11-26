{
  lib,
  fetchzip,
  nfversion,
  pname,
  phash,
  pzip,
  striproot,
}:
fetchzip {
  name = pname;
  stripRoot = striproot;
  url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nfversion}/${pzip}";
  postFetch = ''
    mkdir -p $out/share/fonts/${pname}
    unzip -j $renamed -d $out/share/fonts/${pname} -x LICENSE readme.md README.md
  '';

  sha256 = phash;

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
