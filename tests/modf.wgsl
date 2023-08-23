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
  result += fract_and_whole_vec.whole.x * 7.;
  return result;
}
