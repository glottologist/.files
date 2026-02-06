function env2fish --description "Convert bash .env file to fish-friendly format"
    if test (count $argv) -eq 0
        echo "Usage: env2fish <input.env> [output.env_fish]"
        echo "  If output not specified, creates <input>_fish in same directory"
        return 1
    end

    set -l input_file $argv[1]

    if not test -f $input_file
        echo "Error: File '$input_file' not found"
        return 1
    end

    set -l output_file
    if test (count $argv) -ge 2
        set output_file $argv[2]
    else
        set -l base (string replace -r '\.env$' '' $input_file)
        set output_file "$base.env_fish"
    end

    echo "# Fish environment file generated from $input_file" > $output_file
    echo "# Generated on "(date) >> $output_file
    echo "" >> $output_file

    while read -l line
        set -l trimmed (string trim $line)

        if test -z "$trimmed"
            echo "" >> $output_file
            continue
        end

        if string match -qr '^#' $trimmed
            echo $trimmed >> $output_file
            continue
        end

        set -l clean (string replace -r '^export\s+' '' $trimmed)

        if string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' $clean
            set -l var_name (string split -m1 '=' $clean)[1]
            set -l var_value (string split -m1 '=' $clean)[2]

            set -l unquoted (string replace -r '^["\'](.*)["\']\s*$' '$1' $var_value)

            echo "set -gx $var_name '$unquoted'" >> $output_file
        else
            echo "# Skipped: $line" >> $output_file
        end
    end < $input_file

    echo "Converted: $input_file -> $output_file"
end
