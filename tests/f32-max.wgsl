fn compute() -> f32 {
  if (3.4028234663852886e38 == 3.4028235e38) {
    return 1.;
  } else {
    return 2.;
  }
}
