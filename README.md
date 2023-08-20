# wgpu-computer
Utility to test compute shaders in wgpu.

## Usage
```sh
cargo run -- sample.wgsl
```

The file should contain the body of a `fn compute() -> f32 { <body> }` function, as in `return 1.1;`.

The result of that computation will be output to stdout.

## Compare with browser version
Use https://fornwall.net/webgpu-compute
