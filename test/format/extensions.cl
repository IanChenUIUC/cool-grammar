CLASS Counter INHERITS IO {
  mask : Int <- 0xff;
  banner : String <- """line one
    "quoted" line two""";

  count(n : Int) : Int { FOR (i : Int <- 0, total : Int <- 0; i < n; i <- i + 1) { {
      total <- total + i;
      self@IO.out_int(total);
  } } };

  classify(o : Object) : String { CASE o OF i : Int => "int"; s : String => "string"; x : Object => "other"; ESAC };

  spin() : Object { WHILE NOT isvoid self LOOP { mask <- mask - 1; } POOL };
};
