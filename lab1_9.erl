-module(lab1_9).
-export([start/0, tot/0, dummy1/0, dummy2/0, dummy3/0]).

start() ->
    Pid = spawn(fun() -> loop([]) end),
    register(server, Pid),
    ok.

dummy1() -> server ! {dummy, dummy1}.
dummy2() -> server ! {dummy, dummy2}.
dummy3() -> server ! {dummy, dummy3}.

tot() ->
    server ! {tot, self()},
    receive
        {tot, T} -> T;
        X -> io:format("unknown message ~p~n", [X])
    end.

find(_, []) -> {none};
find(K, [{K, V} | _]) -> {ok, V};
find(K, [_ | T]) -> find(K, T).

set(K, V, []) -> [{K, V}];
set(K, V, [{K, _} | T]) -> [{K, V} | T];
set(K, V, [H | T]) -> [H | set(K, V, T)].

increase_count(K, L) ->
    case find(K, L) of
        {none} -> [{K, 1} | L];
        {ok, V} -> set(K, V + 1, L)
    end.

loop(L) ->
    receive
        {dummy, X} ->
            L2 = increase_count(X, L),
            loop(L2);
        {tot, Pid} ->
            L2 = increase_count(tot, L),
            Pid ! {tot, L2},
            loop(L2)
    end.
