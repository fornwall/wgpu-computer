#!/bin/bash
set -e -u

: "${SHOW_ERRORS:=0}"
TEST_FILTER=""
if [ $# = 1 ]; then
  TEST_FILTER="$1"
fi

git checkout --quiet Cargo.toml

any_error=false

rm -Rf output/
mkdir -p output/tests/

echo "Adapter information"
cargo run --quiet -- --adapter-info
echo

echo "Test runs"
for input_filename in tests/*.wgsl; do
    if [[ "$input_filename" != *"$TEST_FILTER"* ]]; then
        continue
    fi

    disabled_file=$(echo "$input_filename" | sed "s/.wgsl/.nagadisabled/")
    expected_filename=$(echo "$input_filename" | sed "s/.wgsl/.expected/")
    expected_failure=$(echo "$input_filename" | sed "s/.wgsl/.shouldfail/")
    expected_output=$(cat "$expected_filename")
    nagabranch_filename=$(echo "$input_filename" | sed "s/.wgsl/.nagabranch/")
    if [ -f "$nagabranch_filename" ]; then
        echo '[patch."https://github.com/gfx-rs/naga"]' >> Cargo.toml
        cat "$nagabranch_filename" >> Cargo.toml
    fi

    printf "%s" "- $input_filename ..."

    if [ -f "$disabled_file" ]; then
        echo " skipping since disabled"
        continue
    fi

    set +e
    error_output_file=output/${input_filename}.stderr
    actual_output=$(cargo run -q -- "$input_filename" 2> "$error_output_file")
    exit_code=$?
    set -e

    git checkout --quiet Cargo.toml

    if [ "$exit_code" != 0 ]; then
        printf " Error: Failed running - check %s" "$error_output_file" 
        if [ "$SHOW_ERRORS" = "1" ]; then
            cat "$error_output_file"
        fi
        if [ -f "$expected_failure" ]; then
            echo " (error was expected)"
        else
            echo ""
            any_error=true
        fi
    elif [ "$actual_output" = "$expected_output" ]; then
        if [ -f "$expected_failure" ]; then
            echo " Error: Expected to fail"
            any_error=true
        else
            echo " Ok!"
        fi
    else
        if [ -f "$expected_failure" ]; then
            echo " (error was expected)"
        else
            echo " Error: Expected '$expected_output' - got '$actual_output'"
            any_error=true
        fi
    fi
done

if [ $any_error = true ]; then
    exit 1
fi
