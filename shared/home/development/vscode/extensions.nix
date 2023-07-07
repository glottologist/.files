{
  extensions = [
    { name = "bash-ide-vscode";                publisher = "mads-hartmann";      version = "1.11.0";          sha256 = "1hq41fy2v1grjrw77mbs9k6ps6gncwlydm03ipawjnsinxc9rdkp"; }
    { name = "better-comments";                publisher = "aaron-bond";         version = "2.1.0";           sha256 = "0kmmk6bpsdrvbb7dqf0d3annpg41n9g6ljzc1dh0akjzpbchdcwp"; }
    { name = "bracket-pair-colorizer-2";       publisher = "coenraads";          version = "0.2.2";           sha256 = "0nppgfbmw0d089rka9cqs3sbd5260dhhiipmjfga3nar9vp87slh"; }
    { name = "clojure";                        publisher = "avli";               version = "0.13.1";          sha256 = "1qh17lp7xpc9ggf5awya9d65wxxmr0z1cbpb2w6i63w0118iggx8"; }
    { name = "elixir-ls";                      publisher = "jakebecker";         version = "0.9.0";           sha256 = "1qz8jxpzanaccd5v68z4v1344kw0iy671ksi1bmpyavinlxdkmr8"; }
    { name = "errorlens";                      publisher = "usernamehw";         version = "3.4.1";           sha256 = "0caxmf6v0s5kgp6cp3j1kk7slhspjv5kzhn4sq3miyl5jkrn95kx"; }
    { name = "gitlens";                        publisher = "eamodio";            version = "11.7.0";          sha256 = "po8JzwrADPSZY2SBlaX3N6VSURP/PZIGjFhS3hyV8io=";         }
    { name = "idris";                          publisher = "zjhmale";            version = "0.9.8";           sha256 = "1dfh1rgybhnf5driwgxh69a1inyzxl72njhq93qq7mhacwnyfsdp"; }
    #{ name = "ionide-fake";                    publisher = "ionide";             version = "1.2.3";           sha256 = "0ijgnxcdmb1ij3szcjlyxs2lb1kly5l26lg9z2fa7hfn67rrds29"; }
    { name = "ionide-fsharp";                  publisher = "ionide";             version = "5.10.2";          sha256 = "bYbbJMhEcmOXxcUSY6qVJtXx2IjgAzLg3ie1SHsuHDE=";         }
    #{ name = "ionide-paket";                   publisher = "ionide";             version = "2.0.0";           sha256 = "1455zx5p0d30b1agdi1zw22hj0d3zqqglw98ga8lj1l1d757gv6v"; }
    { name = "jinjahtml";                      publisher = "samuelcolvin";       version = "0.16.0";          sha256 = "17f4dzwsqpwdkzc9f35sx31mvb4zns2ya0ym7mjgl8iy1kyci66q"; }
    { name = "language-fstar";                 publisher = "josser";             version = "0.0.1";           sha256 = "0zrv7x60p7b7rs9kxyfarfdhpj9c1xbnpc5m8gj82qfac6mk55d0"; }
    { name = "language-julia";                 publisher = "julialang";          version = "1.1.37";          sha256 = "0kzrc75bkxwppbl2157gmz4b08vffqf4m7jcbfzc0hvfjacp5y23"; }
    { name = "ligo-vscode";                    publisher = "ligolang-publish";   version = "0.5.2";           sha256 = "s/edIFlch6Mrvoaf1cvNXvs9jVUUXpT640z8NXGKc5g=";         }
    { name = "ligo-debugger-vscode";           publisher = "ligolang-publish";   version = "0.0.7";           sha256 = "OsmnyPE1kzlErdXlxcGysP8mZSEQaQKIog+hqJLTFHs=";         }
    { name = "chinstrap";                      publisher = "ant4g0nist";         version = "0.1.2";           sha256 = "vBxrqFXp3lj4xptN021Kaf5U+Y7GQbV89V6ATG4j/+I=";         }
    { name = "taqueria-vscode";                publisher = "ecadlabs";           version = "0.29.0";          sha256 = "aQoKu1bfsEGZokQjd6UR2AQUVzCZ/Xl7VZB5UfzAYq8=";         }
    { name = "markdown-all-in-one";            publisher = "yzhang";             version = "3.4.0";           sha256 = "0ihfrsg2sc8d441a2lkc453zbw1jcpadmmkbkaf42x9b9cipd5qb"; }
    { name = "nix";                            publisher = "bbenoist";           version = "1.0.1";           sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b"; }
    { name = "nix-env-selector";               publisher = "arrterian";          version = "1.0.7";           sha256 = "0mralimyzhyp4x9q98x3ck64ifbjqdp8cxcami7clvdvkmf8hxhf"; }
    { name = "nix-ide";                        publisher = "jnoortheen";         version = "0.1.18";          sha256 = "1v3j67j8bydyqba20b2wzsfximjnbhknk260zkc0fid1xzzb2sbn"; }
    { name = "pine-script-syntax-highlighter"; publisher = "ex-codes";           version = "1.0.1";           sha256 = "1sf20i79ismaw9l652jjxq28pfqplrw3lpxkxsaapjxnm9xhw8dj"; }
    { name = "typescript-hero";                publisher = "rbbit";              version = "3.0.0";           sha256 = "I5Hbwe3E4HDGl2oMgkHYBvhtFA49UERP9WRStQ4hwMk=";         }
    { name = "remote-containers";              publisher = "ms-vscode-remote";   version = "0.209.6";         sha256 = "1dvma7mm0g6mr6yjfy0zbn0k143ag8p40r0kcb9n441w2r817rj8"; }
    { name = "remote-kubernetes";              publisher = "okteto";             version = "0.3.4";           sha256 = "T/xrLAyAUb5S8JXzcWt7ix83YgbzeqoWU3H4Gb7qgJo=";         }
    { name = "remote-ssh";                     publisher = "ms-vscode-remote";   version = "0.71.2021121615"; sha256 = "1lh08157z7lialb0dxls9fhahmf5l9wz6x2anwrnycvs512lpr1p"; }
    { name = "rust-analyzer";                  publisher = "rust-lang";          version = "0.4.1114";        sha256 = "fnB6HlgGDGpT6SxtIEFThul43574D2OufLOi2tIcYPY=";         }
    { name = "rust-pack";                      publisher = "swellaby";           version = "0.2.29";          sha256 = "1y82kjxh8x12jrjq5r4mcp5mfxaahksj3cvnxwfprg11gw0k1vaz"; }
    { name = "toggle-zen-mode";                publisher = "fudd";               version = "1.1.2";           sha256 = "0whmbpnin1r1qnq45fpz7ayp51d4lilvbnv7llqd6jplx5b4n3ds"; }
    { name = "vscode-json-editor";             publisher = "nickdemayo";         version = "0.3.0";           sha256 = "160blmm22j2dsr2ms4b33jvdqnh94hcakvcwhhsyjqxld2x951ri"; }
    { name = "vscode-html-css";                publisher = "ecmel";              version = "1.13.1";          sha256 = "gBfcizgn+thCqpTa8bubh6S77ynBC/Vpc+7n4XOfqzE="; }
    { name = "vscode-css-peek";                publisher = "pranaygp";           version = "4.2.0";           sha256 = "+NLMj/TsZklBGZqlbDDankhNo6M9KSWgEahJpPu48zY="; }
    { name = "vsfstar";                        publisher = "artagnon";           version = "0.0.7";           sha256 = "1sh3aizmsn3jfsn34w4w55x106yfs3qwcjrd0f3kgyksf05avwsw"; }
    { name = "zk-vscode";                      publisher = "mickael-menu";       version = "0.1.0";           sha256 = "HY/wm1AaD1tBQ/nrq8qE1pqWC+BKYjw+51P97yklmrw="; }
  ];
}
