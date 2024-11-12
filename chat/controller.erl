-module(controller).
-export([start/3]).

start(MM, _, _) ->
    io:format("Started controller~n", []),
    process_flag(trap_exit, true),
    chat_server ! {mm, MM, {login}},
    loop(MM).

loop(MM) ->
    receive
        {chan, MM, {msg, Msg, from, User}} ->
            io:format("[controller ~p] Message from ~p: ~p~n", [MM, User, Msg]),
            chat_server ! {mm, MM, {msg, Msg, from, User}},
            loop(MM);
        {'EXIT', Pid, Reason} ->
            io:format("[controller ~p] Process ~p exiting: ~p~n", [MM, Pid, Reason]),
            loop(MM);
        X ->
            io:format("[controller ~p] Received: ~p~n", [MM, X]),
            loop(MM)
    end.
