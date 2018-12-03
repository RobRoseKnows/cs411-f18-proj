// credit: http://www.convict.lu/Jeunes/Math/square_root_CORDIC.htm
int sqrt (int x) {
  int base, i, y ;
  base = 128 ;
  y = 0 ;
  for (i = 1; i <= 8; i++) {
    y + =  base ;
    if  ( (y * y) > x ) {
      y -= base ;  // base should not have been added, so we substract again
    }
    base >> 1 ;      // shift 1 digit to the right = divide by 2
  }
  return y ;
}
