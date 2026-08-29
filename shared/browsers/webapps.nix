{
  pkgs,
  ...
}: let
  brave = "${pkgs.brave}/bin/brave";
  app = url: "${brave} --app=${url}";
in {
  xdg.desktopEntries = {
    hey-email = {
      name = "HEY Email";
      exec = app "https://app.hey.com";
      genericName = "Email";
      categories = ["Network" "Email"];
      terminal = false;
    };
    hey-calendar = {
      name = "HEY Calendar";
      exec = app "https://app.hey.com/calendar";
      genericName = "Calendar";
      categories = ["Office" "Calendar"];
      terminal = false;
    };
    chatgpt-web = {
      name = "ChatGPT";
      exec = app "https://chatgpt.com";
      genericName = "AI chat";
      categories = ["Network"];
      terminal = false;
    };
    grok-web = {
      name = "Grok";
      exec = app "https://grok.com";
      genericName = "AI chat";
      categories = ["Network"];
      terminal = false;
    };
    whatsapp-web = {
      name = "WhatsApp";
      exec = app "https://web.whatsapp.com";
      genericName = "Messaging";
      categories = ["Network" "InstantMessaging"];
      terminal = false;
    };
    youtube-web = {
      name = "YouTube";
      exec = app "https://www.youtube.com";
      genericName = "Video";
      categories = ["AudioVideo"];
      terminal = false;
    };
    x-web = {
      name = "X";
      exec = app "https://x.com";
      genericName = "Social";
      categories = ["Network"];
      terminal = false;
    };
    google-photos-web = {
      name = "Google Photos";
      exec = app "https://photos.google.com";
      genericName = "Photos";
      categories = ["Graphics"];
      terminal = false;
    };
    google-maps-web = {
      name = "Google Maps";
      exec = app "https://maps.google.com";
      genericName = "Maps";
      categories = ["Network"];
      terminal = false;
    };
    zoom-web = {
      name = "Zoom";
      exec = app "https://app.zoom.us/wc";
      genericName = "Video conferencing";
      categories = ["Network"];
      terminal = false;
    };
    basecamp-web = {
      name = "Basecamp";
      exec = app "https://launchpad.37signals.com";
      genericName = "Project management";
      categories = ["Office"];
      terminal = false;
    };
  };
}
