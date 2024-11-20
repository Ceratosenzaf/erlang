-module(node).
-export([start/2, start_print_node/0]).

start(F, PrintNode) ->
    loop(F, -1, none, PrintNode).

start_print_node() ->
    print_node_loop().

loop(F, M, Next, End) ->
    receive
        {next, X} ->
            io:format("[node ~p] received next node ~p~n", [self(), X]),
            loop(F, M, X, End);
        {loops, X} ->
            io:format("[node ~p] received loops ~p~n", [self(), X]),
            Next ! {loops, X},
            loop(F, X, Next, End);
        {data, X, N} ->
            io:format("[node ~p] received data ~p, loops: ~p~n", [self(), X, N]),
            Next ! {loops, N},
            receive
                _ -> ok
            end,
            Next ! {data, F(X)},
            loop(F, N - 1, Next, End);
        {data, X} when M == 0 ->
            io:format("[node ~p] ending~n", [self()]),
            End ! {data, X},
            loop(F, 0, Next, End);
        {data, X} ->
            io:format("[node ~p] received data: ~p, remaining loops: ~p~n", [self(), X, M]),
            Next ! {data, F(X)},
            loop(F, M - 1, Next, End);
        {stop} ->
            io:format("[node ~p] stopping~n", [self()]),
            Next ! {stop};
        X ->
            io:format("[node ~p] received unknown ~p~n", [self(), X]),
            loop(F, M, Next, End)
    end.

print_node_loop() ->
    receive
        {data, X} ->
            io:format("[print node ~p] result: ~p~n", [self(), X]),
            print_node_loop();
        {stop} ->
            io:format("[print node ~p] stopping~n", [self()]);
        X ->
            io:format("[print node ~p] received unknown ~p~n", [self(), X]),
            print_node_loop()
    end.
