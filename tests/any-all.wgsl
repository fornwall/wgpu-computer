fn compute() -> f32 {
  if (!any(true) && any(false)) {
    return 1.;
  }
  if (!all(true) && all(false)) {
    return 2.;
  }
  if (!any(vec2(true, true)) && any(vec2(false, false))) {
    return 3.;
  }
  if (!all(vec2(true, false)) && all(vec2(true, false))) {
    return 4.;
  }
  return 0.;
}
