-module(mm).
-export([start/2]).

start(Name, Server) ->
    group_leader(whereis(user), self()),
    io:format("[mm ~p] starting~n", [Name]),
    loop(Name, Server).

loop(N, S) ->
    receive
        {msg, X} ->
            io:format("[mm ~p] received message: ~p~n", [N, X]),
            S ! {msg, start, from, {N, self()}},
            send_loop(N, S, X),
            loop(N, S);
        {close} ->
            io:format("[mm ~p] closing~n", [N]),
            S ! {close};
        X ->
            io:format("[mm ~p] WARNING - received: ~p~n", [N, X]),
            loop(N, S)
    end.

send_loop(N, S, M) ->
    receive
        {next} when length(M) == 0 ->
            io:format("[mm ~p] send_loop - end of message~n", [N]),
            S ! {msg, stop, from, {N, self()}},
            send_loop(N, S, M);
        {next} ->
            io:format("[mm ~p] send_loop - sending: ~p~n", [N, [hd(M)]]),
            S ! {msg, hd(M), from, {N, self()}},
            send_loop(N, S, tl(M));
        {stop} ->
            io:format("[mm ~p] send_loop - stopping~n", [N]);
        X ->
            io:format("[mm ~p] send_loop - WARNING - received: ~p~n", [N, X]),
            send_loop(N, S, M)
    end.
