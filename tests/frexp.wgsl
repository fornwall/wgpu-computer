fn test(input: f32, expected_fract: f32, expected_exp: i32) -> f32 {
  let res = frexp(input);
  return select(1000., 0., res.fract == expected_fract && res.exp == expected_exp);
}

fn compute() -> f32 {
  // https://www.w3.org/TR/WGSL/#example-450e6187
  // res = fraction * 2^exponent
  // 3 = 0.75 * 2^2

  let fraction_and_exponent = frexp(3.0);
  let fraction_only = frexp(3.0).fract; // 0.75
  let exponent_only = f32(frexp(3.0).exp); // 2

  var result = fraction_only * 10.; // 7.5
  result += exponent_only * 9.; // 18
  result += fraction_and_exponent.fract * 8.; // 6
  result += f32(fraction_and_exponent.exp) * 7.; // 14

  result += f32(frexp(vec2(10.5, 10.5)).exp.y); // 4
  result += f32(frexp(10.5).exp); // 4

  result += frexp(-3.0).fract * 4.0; // -3
  result += f32(frexp(-3.0).exp); // 2

  // CTS, src/unittests/maths.spec.ts
  result += test(0., 0., 0);
  result += test(-0., -0., 0);
  result += test(0.5, 0.5, 0);
  result += test(-0.5, -0.5, 0);
  result += test(1., 0.5, 1);
  result += test(-1., -0.5, 1);
  result += test(2., 0.5, 2);
  result += test(-2., -0.5, 2);
  result += test(10000., 0.6103515625, 14);
  result += test(-10000., -0.6103515625, 14);

  return result;
}
