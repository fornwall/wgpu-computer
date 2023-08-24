fn test(input: f32, expected_fract: f32, expected_whole: f32) -> f32 {
  let res = modf(input);
  return select(1000., 0., res.fract == expected_fract && res.whole == expected_whole);
}

fn compute() -> f32 {
  // https://www.w3.org/TR/WGSL/#example-e7d85833
  // Infers result type
  let fract_and_whole = modf(1.5);
  // Sets fract_only to 0.5
  let fract_only = modf(1.5).fract;
  // Sets whole_only to 1.0
  let whole_only = modf(1.5).whole;

  // Infers result type
  let fract_and_whole_vec = modf(vec2(1.5, 1.5));

  // 0.5 * 10 = 5
  var result = fract_and_whole.fract * 10.;
  // 1.0 * 9 = 9
  result += fract_and_whole.whole * 9.;
  // 0.5 * 8 = 4
  result += fract_only * 8.;
  // 1.0 * 7 = 7
  result += fract_and_whole.whole * 7.;
  // 1.0 * 7 = 7
  result += fract_and_whole_vec.whole.y * 7.;
  result += round(modf(-11.9).fract * 10.); // -9
  result += round(modf(-11.9).whole); // -11

  result += test(0., 0., 0.);
  result += test(1., 0., 1.);
  result += test(-1., 0., -1.);
  result += test(0.5, 0.5, 0.);
  result += test(-0.5, -0.5, 0.);
  result += test(2.5, 0.5, 2.);
  result += test(-2.5, -0.5, -2.);
  result += test(10., 0., 10.);
  result += test(-10., 0., -10.);
/*
  From CTS:
      { input: 0, fract: 0, whole: 0 },
      { input: 1, fract: 0, whole: 1 },
      { input: -1, fract: 0, whole: -1 },
      { input: 0.5, fract: 0.5, whole: 0 },
      { input: -0.5, fract: -0.5, whole: 0 },
      { input: 2.5, fract: 0.5, whole: 2 },
      { input: -2.5, fract: -0.5, whole: -2 },
      { input: 10.0, fract: 0, whole: 10 },
      { input: -10.0, fract: 0, whole: -10 },
*/


  return result;
}
