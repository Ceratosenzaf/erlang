-module(lab1_1).
-export([is_palindrome/1]).

reverse([]) -> [];
reverse([H|T]) -> reverse(T) ++ [H].

is_palindrome(L) -> reverse(L) == L.