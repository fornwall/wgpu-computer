#!/bin/sh
set -e -u

: "${SHOW_ERRORS:=0}"

git checkout --quiet Cargo.toml

any_error=false

rm -Rf output/
mkdir -p output/tests/

for input_filename in tests/*.wgsl; do
    expected_filename=$(echo "$input_filename" | sed "s/.wgsl/.expected/")
    expected_output=$(cat "$expected_filename")
    nagabranch_filename=$(echo "$input_filename" | sed "s/.wgsl/.nagabranch/")
    if [ -f "$nagabranch_filename" ]; then
        echo '[patch."https://github.com/gfx-rs/naga"]' >> Cargo.toml
        cat "$nagabranch_filename" >> Cargo.toml
    fi

    printf "%s" "- $input_filename ..."
    set +e
    error_output_file=output/${input_filename}.stderr
    actual_output=$(cargo run -q -- "$input_filename" 2> "$error_output_file")
    exit_code=$?
    set -e

    git checkout --quiet Cargo.toml

    if [ "$exit_code" != 0 ]; then
        echo " Error: Failed running - check $error_output_file" 
        any_error=true
        if [ "$SHOW_ERRORS" = "1" ]; then
            cat "$error_output_file"
        fi
    elif [ "$actual_output" = "$expected_output" ]; then
        echo " Ok!"
    else
        echo " Error: Expected '$expected_output' - got '$actual_output'"
        any_error=true
    fi
done

if [ $any_error = true ]; then
    exit 1
fi
