-module(lab2_1).
-export([squared_int/1, intersect/2, symmetric_difference/2, symmetric_difference_2/2]).

squared_int(L) -> [X * X || X <- L, is_number(X)].

intersect(A, B) -> [X || X <- A, lists:member(X, B)].

symmetric_difference(A, B) ->
    [X || X <- A ++ B, (not lists:member(X, A)) or (not lists:member(X, B))].

symmetric_difference_2(A, B) -> (A -- B) ++ (B -- A).
