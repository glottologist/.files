{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      nerdfix
      ## ICONS
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
      # weather-icon
      whitesur-icon-theme # macOS-inspired
    ];
  };
}
