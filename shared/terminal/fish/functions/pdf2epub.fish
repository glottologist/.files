function pdf2epub --description "Convert PDF to EPUB without modifying the original"
    set -l usage "Usage: pdf2epub [--force] <file.pdf|dir> [output.epub]
       pdf2epub [--force] <file.pdf|dir> [<file.pdf|dir> ...]
       pdf2epub [--force] <file.pdf|dir> [<file.pdf|dir> ...] <output-dir>"

    set -l force 0
    set -l parse_opts 1
    set -l positional

    for arg in $argv
        if test $parse_opts -eq 1
            switch $arg
                case --
                    set parse_opts 0
                    continue
                case -h --help
                    echo $usage
                    echo
                    echo "Converts each PDF to EPUB with Calibre ebook-convert."
                    echo "A directory argument stands for every .pdf directly inside it."
                    echo "The original PDF is only read; it is never overwritten or deleted."
                    echo "Default output is <same-dir>/<same-name>.epub."
                    echo "When the last argument is a directory and more than one argument"
                    echo "is given, it is the output directory."
                    echo "Scanned PDFs, whose OCR text is invisible, are converted through"
                    echo "pdftohtml -hidden; the images are dropped and the text kept."
                    echo "Use --force to overwrite an existing EPUB."
                    return 0
                case -f --force
                    set force 1
                    continue
                case '-*'
                    echo "[ERROR] Unknown option: $arg" >&2
                    echo $usage >&2
                    return 1
            end
        end
        set -a positional $arg
    end

    if test (count $positional) -eq 0
        echo $usage >&2
        return 1
    end

    if not type -q ebook-convert
        echo "[ERROR] ebook-convert not found in PATH (install calibre)" >&2
        return 127
    end

    set -l output_epub
    set -l output_dir
    set -l inputs $positional

    if test (count $positional) -ge 2
        set -l last $positional[-1]
        if string match -qr -i '\.epub$' -- $last
            if test (count $positional) -ne 2
                echo "[ERROR] An explicit .epub output is only valid with a single PDF" >&2
                return 1
            end
            set output_epub $last
            set inputs $positional[1]
        else if test -d $last
            set output_dir $last
            set inputs $positional[1..-2]
        end
    end

    # Expand directory inputs to the PDFs directly inside them.
    set -l pdfs
    for input in $inputs
        if test -d $input
            set -l found (find $input -mindepth 1 -maxdepth 1 -type f,l -iname '*.pdf' | sort)
            if test (count $found) -eq 0
                echo "[ERROR] No PDF files in directory: $input" >&2
                return 1
            end
            set -a pdfs $found
        else
            set -a pdfs $input
        end
    end

    if test (count $pdfs) -eq 0
        echo "[ERROR] No PDF inputs given" >&2
        echo $usage >&2
        return 1
    end

    if test -n "$output_epub"; and test (count $pdfs) -ne 1
        echo "[ERROR] An explicit .epub output is only valid with a single PDF" >&2
        return 1
    end

    set -l failures 0
    for pdf in $pdfs
        set -l epub
        if test -n "$output_epub"
            set epub $output_epub
        else
            set -l stem (string replace -r -i '\.pdf$' '' -- (path basename $pdf))
            if test -n "$output_dir"
                set epub "$output_dir/$stem.epub"
            else
                set epub (path dirname $pdf)"/$stem.epub"
            end
        end

        __pdf2epub_convert_one $pdf $epub $force
        or set failures (math $failures + 1)
    end

    if test $failures -gt 0
        echo "[ERROR] $failures conversion(s) failed" >&2
        return 1
    end
end

# True when pdftohtml finds no text on the first pages unless told -hidden:
# a scanned PDF whose OCR layer is invisible text, which Calibre's PDF input
# never asks for and so converts to an empty book.
function __pdf2epub_hidden_text --argument-names pdf
    type -q pdftohtml; or return 1
    set -l probe (mktemp -d); or return 1
    set -l pages -f 1 -l 10
    pdftohtml -enc UTF-8 -noframes -nomerge -i -xml $pages $pdf $probe/plain.xml >/dev/null 2>&1
    pdftohtml -enc UTF-8 -noframes -nomerge -i -hidden -xml $pages $pdf $probe/hidden.xml >/dev/null 2>&1
    set -l plain 0
    set -l hidden 0
    test -f $probe/plain.xml; and set plain (grep -c '<text' $probe/plain.xml)
    test -f $probe/hidden.xml; and set hidden (grep -c '<text' $probe/hidden.xml)
    rm -rf $probe
    test $plain -eq 0; and test $hidden -gt 0
end

function __pdf2epub_convert_one --argument-names pdf epub force
    if not test -f $pdf
        echo "[ERROR] Not a file: $pdf" >&2
        return 1
    end

    if not string match -qr -i '\.pdf$' -- $pdf
        echo "[ERROR] Input is not a .pdf file: $pdf" >&2
        return 1
    end

    set -l header (head -c 4 -- $pdf)
    if test "$header" != '%PDF'
        echo "[ERROR] File is not a PDF (missing %PDF header): $pdf" >&2
        return 1
    end

    set -l abs_pdf (path resolve $pdf)
    set -l epub_parent (path dirname $epub)
    if not test -d $epub_parent
        mkdir -p $epub_parent; or begin
            echo "[ERROR] Failed to create directory $epub_parent" >&2
            return 1
        end
    end
    set -l abs_epub "$epub_parent/"(path basename $epub)
    if test -e $epub
        set abs_epub (path resolve $epub)
    end

    if test $abs_pdf = $abs_epub
        echo "[ERROR] Refusing to write EPUB over the source PDF: $pdf" >&2
        return 1
    end

    if test -e $epub; and test $force -ne 1
        echo "[ERROR] EPUB already exists (use --force to overwrite): $epub" >&2
        return 1
    end

    set -l before (stat -c '%Y %s %i' -- $pdf)
    set -l existed 0
    test -e $epub; and set existed 1

    set -l convert_status
    if __pdf2epub_hidden_text $pdf
        echo "[INFO] Converting $pdf -> $epub (scanned: hidden OCR text, images dropped)"
        set -l stem (string replace -r -i '\.pdf$' '' -- (path basename $pdf))
        set -l work (mktemp -d)
        pdftohtml -enc UTF-8 -noframes -nomerge -i -hidden $pdf $work/book.html >/dev/null 2>&1
        and ebook-convert $work/book.html $epub --enable-heuristics --epub-version 3 --title $stem
        set convert_status $status
        rm -rf $work
    else
        echo "[INFO] Converting $pdf -> $epub"
        ebook-convert $pdf $epub --enable-heuristics --epub-version 3
        set convert_status $status
    end

    set -l after (stat -c '%Y %s %i' -- $pdf)
    if test $before != $after
        echo "[ERROR] Original PDF changed during conversion: $pdf" >&2
        return 1
    end

    if test $convert_status -ne 0
        if test $existed -eq 0; and test -e $epub
            rm -f $epub
        end
        echo "[ERROR] Conversion failed: $pdf" >&2
        return 1
    end

    if not test -f $epub
        echo "[ERROR] Conversion reported success but EPUB is missing: $epub" >&2
        return 1
    end

    echo "[INFO] Wrote $epub (original PDF unchanged)"
    return 0
end
