-module(switch).
-export([start/1]).

start(Node) ->
    io:format("[switch ~p] starting~n", [self()]),
    put(receiver_node, Node),
    receive
        {next, X} ->
            io:format("[switch ~p] received next: ~p~n", [self(), X]),
            loop(X);
        X ->
            io:format("[switch ~p] ERROR - received: ~p~n", [self(), X]),
            exit(kill)
    end.

loop(N) ->
    receive
        {start, X} ->
            io:format("[switch ~p] starting communication~n", [self()]),
            {receiver, get(receiver_node)} ! {msg, start},
            N ! {msg, X},
            loop(N);
        {msg, [X | T]} ->
            io:format("[switch ~p] sending message: ~p~n", [self(), X]),
            {receiver, get(receiver_node)} ! {msg, X},
            N ! {msg, T},
            loop(N);
        {msg, []} ->
            io:format("[switch ~p] stopping communication~n", [self()]),
            {receiver, get(receiver_node)} ! {msg, stop},
            loop(N);
        {quit} ->
            io:format("[switch ~p] quitting~n", [self()]);
        X ->
            io:format("[switch ~p] WARNING - received: ~p~n", [self(), X]),
            loop(N)
    end.
