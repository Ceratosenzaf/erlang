-module(client).
-export([convert/5]).

convert(from, From, to, To, V) ->
    From ! {convert, V, to, To, returnTo, self()},
    receive
        {res, X} ->
            io:format("[client] ~p°~p are equivalent to ~p°~p~n", [V, From, X, To]),
            X;
        X ->
            io:format("[client] ⚠️ WARNING - received ~p~n", [X]),
            exit(protocol_error)
    end.