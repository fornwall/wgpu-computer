fn compute() -> f32 {
  if (3.4028234663852886e38 != 3.4028235e38) {
    return 1.;
  } else if (0x1.fffffep+127 != 3.4028235e38) {
    return 2.;
  } else {
    return 3.;
  }
}
