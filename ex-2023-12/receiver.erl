-module(receiver).
-export([start/0]).

start() -> register(receiver, spawn_link(fun() -> loop([]) end)).

loop(M) ->
    receive
        {msg, start} ->
            io:format("[receiver] received start of message, previous message: '~p'~n", [M]),
            loop([]);
        {msg, end} ->
            io:format("[receiver] received end of message, complete message: '~p'~n", [M]),
            loop([]);
        {msg, X} ->
            io:format("[receiver] received message: ~p~n", [X]),
            loop(M ++ X);
        {quit} ->
            io:format("[receiver] quitting~n", []);
        X ->
            io:format("[receiver] WARNING - received: ~p~n", [X]),
            loop(M)
    end.