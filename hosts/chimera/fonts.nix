# A rotated eight-inch panel at roughly 283 DPI punishes a thin font stack, so
# the emoji and symbol coverage that the desktop and the agent CLIs assume is
# declared explicitly here.
#
# Icon themes are deliberately absent from fonts.packages, and that is not an
# oversight: every entry there becomes a fontconfig <dir>, and a program whose
# fontconfig cannot use the prebuilt system cache then rescans millions of SVGs
# before it draws anything. This is the lesson hosts/bebop/fonts.nix records.
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    font-awesome
    symbola
  ];
}
