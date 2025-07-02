{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      symbola
      material-icons
      tela-circle-icon-theme # 🎯 Perfect rounded icons for Catppuccin Latte
      tela-icon-theme # Square version of Tela
      whitesur-icon-theme # macOS-inspired
      fluent-icon-theme # Microsoft Fluent Design
      qogir-icon-theme # Clean and modern
    ];
  };
}
