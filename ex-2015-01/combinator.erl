-module(combinator).
-export([start/2]).


start(N, Max) -> 
    Pids = [spawn(fun() -> generator:start(Max) end) || _ <- lists:seq(1, N)],
    loop(Pids, Max).

get_combinations([], _) -> [[]];
get_combinations([H | T], Max) ->
    lists:foldl(
        fun(_, Acc) ->
            H ! {get, self()},
            receive
                {get, V} ->
                    io:format("[combinator] received ~p~n", [V]),
                    Rest = get_combinations(T, Max),
                    io:format("[combinator] value: ~p, rest: ~p~n", [V, Rest]),
                    Acc ++ [[V | X] || X <- Rest];
                X ->
                    io:format("[combinator] ERROR - received ~p~n", [X]),
                    Acc
            end
        end,
        [],
        lists:seq(1, Max)
    ).

print_combination([X]) -> io:format("~p~n", [X]); 
print_combination([H | T]) -> io:format("~p, ", [H]), print_combination(T).

loop(Pids, Max) ->
    Combinations = get_combinations(Pids, Max),
    lists:foreach(fun(X) -> print_combination(X) end, Combinations).
