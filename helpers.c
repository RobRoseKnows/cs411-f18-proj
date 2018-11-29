int mul_wo_mul(int a, int b) {
    int result = 0;
    for (int i = b; i > 0; i--) {
        result += a;
    }
    // Return result in
    return result;
}