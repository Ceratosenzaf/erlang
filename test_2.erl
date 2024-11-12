-module(test_2).
-export([start_server/0, kill_server/0, stop_server/0]).

start_server() ->
    Pid = spawn(fun() -> loop() end),
    monitor(process, Pid),
    register(server, Pid),
    ok.

handle_death() ->
    receive
        {'DOWN', _, process, Pid, X} ->
            io:format("(~p) process ~p died. Reason: ~p~n", [self(), Pid, X]);
        X ->
            io:format("(~p) received ~p~n", [self(), X])
    end.

kill_server() ->
    server ! {die},
    handle_death().

stop_server() ->
    server ! {stop},
    handle_death().

loop() ->
    receive
        {stop} ->
            io:format("(~p) stopping~n", [self()]);
        {die} ->
            io:format("(~p) about to die~n", [self()]),
            exit(kill);
        X ->
            io:format("(~p) received ~p~n", [self(), X]),
            loop()
    end.
