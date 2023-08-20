#!/bin/sh
set -e -u

any_error=false

for input_filename in tests/*.wgsl; do
    expected_filename=$(echo "$input_filename" | sed "s/.wgsl/.expected/")
    expected_output=$(cat "$expected_filename")
    nagabranch_filename=$(echo "$input_filename" | sed "s/.wgsl/.nagabranch/")
    if [ -f "$nagabranch_filename" ]; then
        while read -r naga_repo && read -r naga_branch; do
            printf "[patch.\"https://github.com/gfx-rs/naga\"]\nnaga = { git = \"%s\", branch = \"%s\" }" "$naga_repo" "$naga_branch" >> Cargo.toml
        done < "$nagabranch_filename"
    fi

    printf "%s" "Checking $input_filename ..."
    actual_output=$(cargo run -q -- "$input_filename")

    git checkout --quiet Cargo.toml

    if [ "$actual_output" = "$expected_output" ]; then
        echo " Ok!"
    else
        echo ""
        echo "Error: Expected '$expected_output' - got '$actual_output'"
        any_error=true
    fi
done

if [ $any_error = true ]; then
    exit 1
fi
