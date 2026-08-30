{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      nerdfix
    ];
  };

  # Icon themes belong on XDG_DATA_DIRS, not in fonts.packages: every entry
  # there becomes a fontconfig <dir>, and programs whose fontconfig cannot use
  # the prebuilt system cache (the caelestia shell links a newer fontconfig
  # from nixpkgs-unstable) then rescan millions of SVGs before drawing.
  environment.systemPackages = with pkgs; [
    fluent-icon-theme # Microsoft Fluent Design
    geticons
    super-tiny-icons
    zafiro-icons
    marwaita-icons
    gruvbox-plus-icons
    cosmic-icons
    candy-icons
    humanity-icon-theme
    icon-library
    material-black-colors
    material-icons
    material-design-icons
    material-symbols
    qogir-icon-theme # Clean and modern
    swaycons
    nixos-icons
    line-awesome
    iso-flags
    tela-circle-icon-theme # 🎯 Perfect rounded icons for Catppuccin Latte
    tela-icon-theme # Square version of Tela
    unidings
    whitesur-icon-theme # macOS-inspired
  ];
}
