-module(lab1_3).
-export([factors/1]).

factors(N) when N > 1 -> [
  X || X <- lists:seq(2, trunc(math:sqrt(N))),
  (N rem X == 0) and (factors(X) == [])
];
factors(_) -> [].