-module(lab1_2).
-export([is_an_anagram/2]).

is_anagram(A, B) -> (A -- B) == "".

is_an_anagram(S, []) -> false;
is_an_anagram(S, [H|T]) -> is_anagram(S, H) or is_an_anagram(S, T). 