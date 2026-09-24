-- file header
class Commented { -- after class brace
  (* before attribute *) a : Int;
  b : Int; -- trailing attribute


  -- two blank lines above collapse to one
  m(x : Int) : Int { -- after method brace
    { -- after block brace
      a <- x; (* trailing block comment *)
      -- own line in block
      if x = 0 then -- after then
        1
      else
        f(x, -- inside arguments
          2)
      fi;
    }
  };
  -- before closing brace
};
