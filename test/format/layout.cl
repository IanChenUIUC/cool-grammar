class Empty {};

class Layout inherits Empty {
  f(a : Int, b : Int, c : Int) : Int { a + b * c };

  g() : Int {
    let x : Int <- 1, y : Int <- 2 in let z : Int <- 3 in
      f(x,
        if y < z then y else z fi,
        { z; })
  };

  h() : Bool { if isvoid new Empty then not true else ~1 <= 2 fi };

  k() : Object {
    (new Layout)@Empty.copy().type_name().concat("x")
  };
};
