function value_study
    if test (count $argv) -lt 1; or test (count $argv) -gt 2
        echo "Usage: value_study IMAGE [TONES]"
        echo "Reduces IMAGE to TONES flat values (default 5) and writes one cumulative"
        echo "wash mask per tonal boundary, ordered light to dark."
        return 1
    end

    set -l image $argv[1]
    set -l tones 5
    if test (count $argv) -eq 2
        set tones $argv[2]
    end

    if not test -f "$image"
        echo "value_study: no such file: $image"
        return 1
    end

    if not string match -qr '^[0-9]+$' -- $tones
        echo "value_study: TONES must be a whole number, got: $tones"
        return 1
    end

    if test $tones -lt 2
        echo "value_study: TONES must be at least 2, got: $tones"
        return 1
    end

    set -l base (path change-extension '' -- $image)

    # Softening before posterising merges fiddly detail into masses large enough
    # to paint; without it the value map breaks into unusable speckle.
    magick "$image" -colorspace Gray -blur 0x2 -posterize $tones "$base-values.png"
    or return 1

    for i in (seq 1 (math $tones - 1))
        set -l cut (math "round(100 * $i / $tones)")
        magick "$image" -colorspace Gray -blur 0x2 -threshold $cut% "$base-value-$cut.png"
        or return 1
    end

    echo "$base-values.png ($tones tones)"
    echo (math $tones - 1)" wash masks: $base-value-*.png"
end
