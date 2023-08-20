#!/bin/sh
set -e -u

git checkout --quiet Cargo.toml

any_error=false

for input_filename in tests/*.wgsl; do
    expected_filename=$(echo "$input_filename" | sed "s/.wgsl/.expected/")
    expected_output=$(cat "$expected_filename")
    nagabranch_filename=$(echo "$input_filename" | sed "s/.wgsl/.nagabranch/")
    if [ -f "$nagabranch_filename" ]; then
        echo '[patch."https://github.com/gfx-rs/naga"]' >> Cargo.toml
        cat "$nagabranch_filename" >> Cargo.toml
        echo Cargo.toml
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
