function pad_mp4 --description "Append random padding to every MP4 in a directory"
    set -l usage "Usage: pad_mp4 <megabytes> <directory>"

    for arg in $argv
        switch $arg
            case -h --help
                echo $usage
                echo
                echo "Appends <megabytes> MB of random bytes to every .mp4 directly"
                echo "inside <directory>, in place."
                echo
                echo "Players and MIME sniffing both ignore trailing bytes, so a padded"
                echo "file still reports as video/mp4 and still plays. That is what makes"
                echo "this the quick way to an upload-size test file: generating the bulk"
                echo "locally beats downloading it. Random bytes rather than zeros, which"
                echo "a platform that compresses or deduplicates on ingest would squeeze"
                echo "back to nothing and defeat the test."
                echo
                echo "The padding cannot be told from the video once written, so run this"
                echo "over copies rather than over anything worth keeping."
                return 0
        end
    end

    if test (count $argv) -ne 2
        echo $usage >&2
        return 1
    end

    set -l megabytes $argv[1]
    set -l dir $argv[2]

    if not string match -qr '^[0-9]+$' -- $megabytes; or test $megabytes -eq 0
        echo "[ERROR] Megabytes must be a positive whole number: $megabytes" >&2
        return 1
    end

    if not test -d $dir
        echo "[ERROR] Not a directory: $dir" >&2
        return 1
    end

    # Files only, and only the ones directly inside: following a symlink would
    # pad whatever it points at, somewhere the caller never named.
    set -l mp4s (find $dir -mindepth 1 -maxdepth 1 -type f -iname '*.mp4' | sort)

    if test (count $mp4s) -eq 0
        echo "[ERROR] No MP4 files in directory: $dir" >&2
        return 1
    end

    set -l failures 0
    for mp4 in $mp4s
        set -l before (stat -c %s -- $mp4)

        if dd if=/dev/urandom bs=1M count=$megabytes status=none >>$mp4
            set -l after (stat -c %s -- $mp4)
            echo "[INFO] Padded $mp4: "(numfmt --to=iec $before)" -> "(numfmt --to=iec $after)
        else
            # A short write leaves the file part-padded rather than untouched;
            # say so, because its size is now neither the old one nor the
            # requested one.
            echo "[ERROR] Padding failed, file may be part-padded: $mp4" >&2
            set failures (math $failures + 1)
        end
    end

    if test $failures -gt 0
        echo "[ERROR] $failures file(s) failed to pad" >&2
        return 1
    end

    echo "[INFO] Padded "(count $mp4s)" file(s) by $megabytes MB each"
    return 0
end
