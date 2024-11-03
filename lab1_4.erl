-module(lab1_4).
-export([is_proper/1]).

divisors(N) -> [
  X || X <- lists:seq(1, trunc(N/2)),
  N rem X == 0
].

sum([]) -> 0;
sum([H|T]) -> H + sum(T). 

is_proper(N) -> sum(divisors(N)) == N.