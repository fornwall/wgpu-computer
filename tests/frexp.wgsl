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

  return result;
}
