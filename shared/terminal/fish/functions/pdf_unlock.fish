function pdf_unlock --description "Save an unlocked PDF using a known password"
    if test (count $argv) -eq 1; and contains -- "$argv[1]" -h --help
        echo 'Usage: pdf_unlock <input.pdf> [output.pdf]'
        echo 'Prompts for the password; defaults to <input>-unlocked.pdf. Never overwrites files.'
        return 0
    end
    if test (count $argv) -lt 1; or test (count $argv) -gt 2
        echo 'Usage: pdf_unlock <input.pdf> [output.pdf]' >&2
        return 1
    end
    if not command -q qpdf
        echo 'pdf_unlock: qpdf is not installed' >&2
        return 127
    end
    set -l input (path resolve -- "$argv[1]")
    if not test -f "$input"
        echo 'pdf_unlock: input must be an existing file' >&2
        return 1
    end
    set -l output (string replace -ri '\.pdf$' '' -- "$input")-unlocked.pdf
    if test (count $argv) -eq 2
        set output "$argv[2]"
    end
    if test -e "$output"; or test -L "$output"
        echo 'pdf_unlock: output already exists; choose a different filename' >&2
        return 1
    end
    set output (path resolve -- "$output")
    read --local --silent --prompt-str 'PDF password: ' pdf_unlock_password; or return 1
    set -l temporary (mktemp -- (path dirname -- "$output")/.pdf-unlock.XXXXXX); or return 1
    printf '%s\n' "$pdf_unlock_password" | command qpdf --password-file=- --decrypt "$input" "$temporary"
    set -l result $status
    set -e pdf_unlock_password
    if test $result -eq 0; or test $result -eq 3
        # Publish without overwriting even if another process creates the destination.
        command ln -T -- "$temporary" "$output"
        or set result 1
    end
    command rm -- "$temporary"; or return 1
    if test $result -eq 0; or test $result -eq 3
        printf 'Wrote %s\n' "$output"
    end
    return $result
end
