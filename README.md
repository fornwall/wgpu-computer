# wgpu-computer
Utility project to test compute shaders in both [wgpu](https://github.com/gfx-rs/wgpu) and browsers.

## Usage
```sh
cargo run -- sample.wgsl
```

The file should contain the body of a `fn compute() -> f32 { <body> }` function, as in `return 1.1;`.

The result of that computation will be output to stdout.

## Compare with browser version
Use https://fornwall.net/webgpu-compute

## Test suite
The [tests/](tests/) directory contains a test suite. Each `${NAME}.wgsl` file there contains a `fn compute() -> f32` function which is expected to return the value listed in the `${NAME}.expected`.

Optionally a `${NAME}.nagabranch` file contains information about a specific naga branch which will be used for the test.

## Running test suite against wgpu
Execute `./run-tests.sh`.

## Running test suite against a browser
Execute `./run-browser-tests.py`. That script generates and opens a self-contained `test.html` file.
