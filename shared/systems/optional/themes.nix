{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     adapta-kde-theme     # A port of the adapta theme for Plasma
     adementary-theme     # Adwaita-based GTK theme with design influence from elementary OS and Vertex GTK theme
     amber-theme          # GTK, gnome-shell and Xfce theme based on Ubuntu Ambiance
     ant-nebula-theme     # Nebula variant of the Ant theme
     ant-theme            # A flat and light theme with a modern look
     mojave-gtk-theme     # Mac OSX Mojave like theme for GTK based desktop environments
     nordic               # Gtk and KDE themes using the Nord color pallete
   ];
}
