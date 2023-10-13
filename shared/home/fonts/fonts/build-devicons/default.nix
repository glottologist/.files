{
  lib,
  fetchzip,
  dcversion,
  pname,
  phash,
  striproot,
}:
fetchzip {
  name = pname;
  stripRoot = striproot;
  url = "https://github.com/devicons/devicon/archive/refs/tags/v${dcversion}.zip";
  postFetch = ''
    mkdir -p $out/share/fonts/${pname}
    unzip -j $renamed -d $out/share/fonts/${pname}
  '';

  sha256 = phash;

  meta = with lib; {
    description = ''
      Devicon aims to gather all logos representing development languages and tools. Each icon comes in several versions: font/SVG, original/plain/line, colored/not colored, wordmark/no wordmark. Devicon has 150+ icons. And it's growing!
    '';
    homepage = https://github.com/devicons/devicon;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
