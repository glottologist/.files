{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    #obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    adobe-reader # PDF Reader
    mdbook # Create books from Markdown
    mdbook-katex # A backend for mdBook written in Rust for latex
    mdbook-mermaid # A backend for mdBook written in Rust for mermaid
    mdbook-pdf # A backend for mdBook written in Rust for generating PDF
    mdslides # A slideshow presentation tool
    notepadqq # Notepad++-like editor for the Linux desktop
    slides #Terminal based presentation tool
    slippy # MArkdown slideshows in Rust
    tdf #Tui-based PDF viewer
    texmaker # TeX and LaTeX editor
    texstudio # TeX and LaTeX editor
    zathura #Highly customizable and functional PDF viewer
    wkhtmltopdf # Tools for rendering web pages to PDF or images (binary package)
  ];
}
