{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mdbook # Create books from Markdown
    mdbook-katex # A backend for mdBook written in Rust for latex
    mdbook-mermaid # A backend for mdBook written in Rust for mermaid
    mdbook-pdf # A backend for mdBook written in Rust for generating PDF
    notepadqq # Notepad++-like editor for the Linux desktop
    obsidian # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    texmaker # TeX and LaTeX editor
    texstudio # TeX and LaTeX editor
    slides #Terminal based presentation tool
    slippy # MArkdown slideshows in Rust
    mdslides # A slideshow presentation tool
  ];
}
