fn compute() -> f32 {
    let v = vec2(12.0, 12.0);

    var result = 0.0;

    result += (v + 2.0).x; // + 14 = 14
    result += (2.0 + v).x; // + 14 = 28

    result += (v - 10.0).x; // + 2 = 30
    result += (14.0 - v).x; // + 2 = 32

    result += (v / 2.0).x; // + 6 = 38
    result += (72.0 / v).x; // + 6 = 44

    result += (v * 0.5).x; // + 6 = 50
    result += (0.5 * v).x; // + 6 = 56

    result += (v % 10.0).x; // + 2 = 58
    result += (14.0 % v).x; // + 2 = 60

    return result;
}
