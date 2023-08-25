fn test(e1: f32, e2: i32, expected_result: f32) -> f32 {
  let res = ldexp(e1, e2);
  return select(1000., 0., res == expected_result);
}

fn compute() -> f32 {
  var result = ldexp(2.0, 2);

  // cts, src/unittests/floating_point.spec.ts:
  result += test(0., 0, 0.);
  result += test(0., 1, 0.);
  result += test(0., -1, 0.);
  result += test(1., 1, 2.);
  result += test(1., -1, 0.5);
  result += test(-1., 1, -2.);
  result += test(-1., -1, -0.5);

  return result;
}
