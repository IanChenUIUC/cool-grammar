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
      f( -- after open paren
        x);
      f(x, -- before a later comma
        2, 3);
      f(x, 2, -- after a later comma
        3);
    }
  };
  -- before closing brace
};
