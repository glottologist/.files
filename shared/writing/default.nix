# Writing — the prose side of the machine, as distinct from documentation.
#
# shared/documentation is about producing technical artefacts: mdBook, LaTeX
# editors, PDF tooling. This module is about the writing itself — the editors a
# writer reaches for, the linters that read prose rather than code, the
# dictionaries that make British spelling the default, and the readers that put
# the result in front of a person.
#
# The dictionaries are en_GB deliberately: -ise endings, matching the house
# style this repository's prose follows.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Notes and long-form editors
    apostrophe # Distraction-free GTK Markdown editor
    focuswriter # Full-screen, hide-everything writing environment
    kdePackages.ghostwriter # Markdown editor with a live preview
    logseq # Outliner and journal over a local Markdown graph
    manuskript # Novel-writing tool with outline and character tracking
    marktext # Real-time-preview Markdown editor
    novelwriter # Plain-text novel editor with a project structure
    obsidian # Linked-note vault over local Markdown
    zettlr # Markdown editor with Zettelkasten and citation support
    zk # Command-line Zettelkasten over a plain Markdown notebook

    # Prose linting and grammar
    harper # Fast grammar checker, usable as a language server
    languagetool # Grammar, style and spelling checker
    proselint # Linter for prose style
    vale # Configurable syntax-aware prose linter
    vale-ls # Vale as a language server
    write-good # Naive linter for English prose

    # Spelling, in British English
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    hunspell
    hunspellDicts.en_GB-ise

    # Conversion and office
    libreoffice # Office suite, for the documents other people send
    pandoc # Convert between every document format worth naming

    # Reading
    calibre # Ebook library management and conversion
    foliate # EPUB reader
    sioyek # PDF reader built for papers and technical reading
    xournalpp # Handwritten annotation, for the Pocket 3's touchscreen
  ];
}
