-module(generator).
-export([start/1]).

start(Max) ->
    io:format("[generator ~p] starting~n", [self()]),
    loop(0, Max).

loop(N, Max) ->
    receive
        {get, Pid} ->
            V = N + 1,
            io:format("[generator ~p] getting ~p~n", [self(), V]),
            Pid ! {get, V},
            loop(V rem Max, Max);
        X ->
            io:format("[generator ~p] ERROR - received ~p~n", [self(), X]),
            loop(N, Max)
    end.