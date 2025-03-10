export GPG_TTY=$(tty)
touch ~/.gnupg/gpg-agent.conf
echo 'allow-loopback-pinentry' > ~/.gnupg/gpg-agent.conf
echo 'pinentry-program /usr/bin/pinentry-curses' > ~/.gnupg/gpg-agent.conf

pamac install --no-confirm slack-desktop-wayland
pamac install --no-confirm zoom
pamac install --no-confirm autoconf
pamac install --no-confirm brave-browser
pamac install --no-confirm veracrypt
pamac install --no-confirm nordvpn-bin
pamac install --no-confirm keybase-bin
pamac install --no-confirm syncthing
pamac install --no-confirm virtualbox
pamac install --no-confirm binutils
pamac install --no-confirm bison
pamac install --no-confirm btchip-udev
pamac install --no-confirm cmake
pamac install --no-confirm coreutils
pamac install --no-confirm discord
pamac install --no-confirm dotnet-sdk
pamac install --no-confirm dropbox
pamac install --no-confirm elixir
pamac install --no-confirm erlang
pamac install --no-confirm ethtool
pamac install --no-confirm gcc
pamac install --no-confirm guile
pamac install --no-confirm hidapi
pamac install --no-confirm jdk
pamac install --no-confirm jq
pamac install --no-confirm jre
pamac install --no-confirm julia
pamac install --no-confirm kotlin
pamac install --no-confirm ledger-udev
pamac install --no-confirm leiningen-with-completion
pamac install --no-confirm nodejs
pamac install --no-confirm noto-fonts-emoji
pamac install --no-confirm npm
pamac install --no-confirm ntfs-3g
pamac install --no-confirm nvm
pamac install --no-confirm ocaml
pamac install --no-confirm opam
pamac install --no-confirm podman
pamac install --no-confirm podman-compose
pamac install --no-confirm python
pamac install --no-confirm snapd
pamac install --no-confirm yarn
pamac install --no-confirm zig
pamac install --no-confirm tradingview
pamac install --no-confirm notion-app-enhanced

