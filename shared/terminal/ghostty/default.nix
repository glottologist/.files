{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
  };
  home.file."./.config/ghostty/config".text = ''

    adjust-cell-height = 10%
    window-theme = light
    window-height = 32
    window-width = 110
    background-opacity = 0.99
    background-blur-radius = 60
    cursor-style = bar
    mouse-hide-while-typing = true

    # Catppuccin Latte color scheme
    background = #eff1f5
    foreground = #4c4f69
    cursor-color = #4c4f69
    selection-background = #ccd0da
    selection-foreground = #4c4f69

    # ANSI colors (regular)
    palette = 0=#5c5f77
    palette = 1=#d20f39
    palette = 2=#40a02b
    palette = 3=#df8e1d
    palette = 4=#1e66f5
    palette = 5=#ea76cb
    palette = 6=#179299
    palette = 7=#acb0be

    # ANSI colors (bright)
    palette = 8=#6c6f85
    palette = 9=#d20f39
    palette = 10=#40a02b
    palette = 11=#df8e1d
    palette = 12=#1e66f5
    palette = 13=#ea76cb
    palette = 14=#179299
    palette = 15=#bcc0cc

    # keybindings
    keybind = alt+s>r=reload_config
    keybind = alt+s>x=close_surface

    keybind = alt+s>n=new_window

    # tabs
    keybind = alt+s>c=new_tab
    keybind = alt+s>shift+l=next_tab
    keybind = alt+s>shift+h=previous_tab
    keybind = alt+s>comma=move_tab:-1
    keybind = alt+s>period=move_tab:1

    # quick tab switch
    keybind = alt+s>1=goto_tab:1
    keybind = alt+s>2=goto_tab:2
    keybind = alt+s>3=goto_tab:3
    keybind = alt+s>4=goto_tab:4
    keybind = alt+s>5=goto_tab:5
    keybind = alt+s>6=goto_tab:6
    keybind = alt+s>7=goto_tab:7
    keybind = alt+s>8=goto_tab:8
    keybind = alt+s>9=goto_tab:9

    # split
    keybind = alt+s>\=new_split:right
    keybind = alt+s>-=new_split:down

    keybind = alt+s>j=goto_split:bottom
    keybind = alt+s>k=goto_split:top
    keybind = alt+s>h=goto_split:left
    keybind = alt+s>l=goto_split:right

    keybind = alt+s>z=toggle_split_zoom

    keybind = alt+s>e=equalize_splits

    # other
    #copy-on-select = clipboard

    font-size = 12
    #font-family = JetBrainsMono Nerd Font Mono
    #font-family-bold = JetBrainsMono NFM Bold
    #font-family-bold-italic = JetBrainsMono NFM Bold Italic
    #font-family-italic = JetBrainsMono NFM Italic

    font-family = BerkeleyMono Nerd Font
    #font-family = Iosevka Nerd Font
    # font-family = SFMono Nerd Font

    title = "GhosTTY"

    wait-after-command = false
    shell-integration = detect
    window-save-state = always
    gtk-single-instance = true
    unfocused-split-opacity = 0.8
    quick-terminal-position = center
    shell-integration-features = cursor,sudo
  '';
}
