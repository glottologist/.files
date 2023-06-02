{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    briss                     # Java application for cropping PDF files
    diff-pdf                  # Simple tool for visually comparing two PDF files
    freeoffice                # An office suite with a word processor, spreadsheet and presentation program
    img2pdf                   # Convert images to PDF via direct JPEG inclusion
    latex2html                # LaTeX-to-HTML translator
    libreoffice               # Comprehensive, professional-quality productivity suite, a variant of openoffice.org
    masterpdfeditor           # Master PDF Editor
    mdbook                    # Create books from Markdown
    mdbook-katex              # A backend for mdBook written in Rust for latex
    mdbook-mermaid            # A backend for mdBook written in Rust for mermaid
    mdbook-pdf                # A backend for mdBook written in Rust for generating PDF
    notepadqq                 # Notepad++-like editor for the Linux desktop
    obsidian                  # A powerful knowledge base that works on top of a local folder of plain text Markdown files
    pandoc                    # Conversion between markup formats
    pandoc-plantuml-filter    # Pandoc filter which converts PlantUML code blocks to PlantUML images
    pdf-parser                # Parse a PDF document
    pdf-quench                # A visual tool for cropping pdf files
    pdfarranger               # Merge or split pdfs
    pdfchain                  # A graphical user interface for the PDF toolkit
    pdfcpu                    # A PDF processor written in Go
    pdfcrack                  # Small command line tool for recovering passwords
    pdfgrep                   # Command line utility to search text in PDF files
    pdfminer                  # PDF parser and analyzer
    pdfslicer                 # A simple application to extract, merge, rotate, and reorder pages of PDFs
    pdftk                     # Command line tool for working with PDF
    plantuml                  # Draw UML diagrams using a simple and human readable text description
    plantuml-server           # A web application to generate UML diagrams on-the-fly.
    texmaker                  # TeX and LaTeX editor
    texstudio                 # TeX and LaTeX editor
    wkhtmltopdf               # Tools for rendering web pages to PDF or images (binary package)
  ];
}
