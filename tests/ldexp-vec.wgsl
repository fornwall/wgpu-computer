fn compute() -> f32 {
    let vv = ldexp(vec2(2.0, 3.0), vec2(2, 3));
    return vv.x + vv.y;
}
