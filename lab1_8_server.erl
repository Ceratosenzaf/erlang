-module(lab1_8_server).
-export([start/0, print/1, stop/0]).

start() ->
    erlang:set_cookie(my_secret_cookie),
    Pid = spawn(fun() -> loop() end),
    register(server, Pid),
    ok.

print(M) ->
    server ! {message, M},
    ok.

stop() ->
    server ! {stop},
    ok.

loop() ->
    receive
        {message, M} ->
            io:format("~p~n", [M]),
            loop();
        {stop} ->
            io:format("stopping ~n", [])
    end.
