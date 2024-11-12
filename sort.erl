-module(sort).
-export([merge_sort/1, quick_sort/1, selection_sort/1, insertion_sort/1]).

% merge sort
merge_sort([]) ->
    [];
merge_sort([H]) ->
    [H];
merge_sort(Lst) ->
    N = length(Lst),
    M = N / 2,
    L = [X || {X, I} <- lists:zip(Lst, lists:seq(1, N)), I =< M],
    R = [X || {X, I} <- lists:zip(Lst, lists:seq(1, N)), I > M],
    lists:merge(merge_sort(L), merge_sort(R)).

% quick sort
quick_sort([]) ->
    [];
quick_sort([H | T]) ->
    L = [X || X <- T, X =< H],
    R = [X || X <- T, X > H],
    quick_sort(L) ++ [H] ++ quick_sort(R).

% selection sort
selection_sort([]) ->
    [];
selection_sort(L) ->
    Min = lists:min(L),
    NewL = L -- [Min],
    [Min | selection_sort(NewL)].

% insertion sort
insert(X, []) ->
    [X];
insert(X, [H | T]) when X =< H ->
    [X | [H | T]];
insert(X, [H | T]) ->
    [H | insert(X, T)].

insertion_sort([]) ->
    [];
insertion_sort([H | T]) ->
    insert(H, insertion_sort(T)).
