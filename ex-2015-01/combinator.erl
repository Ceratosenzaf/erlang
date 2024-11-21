-module(combinator).
-export([start/2]).


start(N, Max) -> 
    Pids = [spawn(fun() -> generator:start(Max) end) || _ <- lists:seq(1, N)],
    loop(Pids, Max).

get_combinations([], _) -> [[]];
get_combinations([H | T], Max) ->
    lists:map(
        fun(_) ->
            H ! {get, self()},
            receive
                {get, V} ->
                    io:format("[combinator] received ~p~n", [V]),
                    Rest = get_combinations(T, Max),
                    io:format("[combinator] value: ~p, rest: ~p~n", [V, Rest]),
                    Return =  [[V | X] || X <- Rest],  % TODO: fix
                    io:format("[combinator] test: ~p~n", [Return]),
                    Return;
                X ->
                    io:format("[combinator] ERROR - received ~p~n", [X]),
                    []
            end
        end,
        lists:seq(1, Max)
    ).


loop(Pids, Max) ->
    get_combinations(Pids, Max).
