// This is a multiply function that multiplies a float by an integer by repeatedly
// adding it. Only the float can be negative or have decimal.
float mul_wo_mul(float can_neg, int non_neg) {
    float result = 0;
    for (int i = non_neg; i > 0; i--) {
        // Add repeatedly
        result += can_neg;
    }
    // We'll return the result in a register for reals, bbut lets treat it like a
    // function for simplicity for now.
    return result;
}

// This is just an example main() method.
int main() {
    const float x = mul_wo_mul(1.5, 3);
}
