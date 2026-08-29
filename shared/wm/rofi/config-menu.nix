{...}: {
  home.file.".config/rofi/config-menu.rasi".text = ''
    @import "~/.config/rofi/config.rasi"
    configuration {
      show-icons: false;
      font: "JetBrainsMono Nerd Font Mono 13";
    }
    window {
      width: 320px;
      border: 2px;
      border-color: @border-color;
      border-radius: 16px;
    }
    mainbox {
      orientation: vertical;
      spacing: 0px;
      children: [ "inputbar", "listbox" ];
    }
    imagebox {
      enabled: false;
    }
    mode-switcher {
      enabled: false;
    }
    dummy {
      enabled: false;
    }
    inputbar {
      enabled: true;
      spacing: 8px;
      padding: 12px 14px;
      margin: 12px 12px 4px 12px;
      border-radius: 12px;
      background-color: @bg-alt;
      text-color: @foreground;
      children: [ "prompt", "entry" ];
    }
    prompt {
      enabled: true;
      background-color: inherit;
      text-color: inherit;
    }
    textbox-prompt-colon {
      enabled: false;
    }
    entry {
      padding: 0px;
      background-color: inherit;
      text-color: inherit;
      placeholder: "";
      placeholder-color: inherit;
      cursor: text;
    }
    listbox {
      padding: 8px 10px 12px 10px;
      spacing: 0px;
      background-color: transparent;
    }
    listview {
      lines: 12;
      columns: 1;
      spacing: 2px;
      cycle: true;
      dynamic: true;
      scrollbar: false;
      fixed-height: false;
      background-color: transparent;
    }
    element {
      padding: 10px 12px;
      spacing: 10px;
      border-radius: 10px;
      background-color: transparent;
      text-color: @text-color;
    }
    element selected.normal {
      background-color: @selected;
      text-color: @text-selected;
    }
    element-text {
      background-color: transparent;
      text-color: inherit;
      vertical-align: 0.5;
      horizontal-align: 0.0;
    }
    message {
      padding: 0px;
      background-color: transparent;
    }
    textbox {
      padding: 8px 12px;
      border-radius: 10px;
      background-color: @bg-alt;
      text-color: @foreground;
    }
  '';
}
