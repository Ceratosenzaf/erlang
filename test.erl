-module(test).
-export([start_server/0, start_server/1, kill_server/0, stop_server/0]).

start_server() -> start_server(false).
start_server(Admin) ->
    if
        Admin ->
            process_flag(trap_exit, true),
            io:format("(~p) starting as admin~n", [self()]);
        true ->
            io:format("(~p) starting as non admin~n", [self()])
    end,
    Pid = spawn_link(fun() -> loop() end),
    register(server, Pid),
    ok.

handle_death() ->
    receive
        {'EXIT', Pid, X} -> io:format("(~p) process ~p died. Reason: ~p~n", [self(), Pid, X]);
        X -> io:format("(~p) received ~p~n", [self(), X])
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
