-module(converter).
-export([start/3]).

start(U, FromC, ToC) ->
    io:format("[converter ~p] starting~n", [U]),
    loop(U, FromC, ToC).

loop(U, FromC, ToC) ->
    receive
        {convert, X, to, To, returnTo, Client} ->
            io:format("[converter ~p] converting ~p to 'C' and passing to ~p~n", [U, X, To]),
            To ! {convert, ToC(X), returnTo, Client},
            loop(U, FromC, ToC);
        {convert, X, returnTo, Client} ->
            io:format("[converter ~p] converting ~p from 'C'~n", [U, X]),
            Client ! {res, FromC(X)},
            loop(U, FromC, ToC);
        X ->
            io:format("[converter ~p] ⚠️ WARNING - received ~p~n", [U, X]),
            loop(U, FromC, ToC)
    end.