{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    freeoffice                # An office suite with a word processor, spreadsheet and presentation program
    libreoffice               # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
    briss                     # Java application for cropping PDF files
    diff-pdf                  # Simple tool for visually comparing two PDF files
    img2pdf                   # Convert images to PDF via direct JPEG inclusion
    latex2html                # LaTeX-to-HTML translator
    mdbook                    # Create books from MarkDown
    notepadqq                 # Notepad++-like editor for the Linux desktop
    obsidian                  # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    pandoc                    # Conversion between markup formats
    pandoc-plantuml-filter    # Pandoc filter which converts PlantUML code blocks to PlantUML images
    plantuml                  # Draw UML diagrams using a simple and human readable text description
    plantuml-server           # A web application to generate UML diagrams on-the-fly.
    texmaker                  # TeX and LaTeX editor
    texstudio                 # TeX and LaTeX editor
  ];
}
