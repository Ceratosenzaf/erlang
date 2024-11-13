-module(controller).
-export([start/3]).

start(MM, User, _) ->
    io:format("[controller ~p] Started~n", [MM]),
    process_flag(trap_exit, true),
    chat_server ! {mm, MM, {login, User}},
    loop(MM, User).

loop(MM, User) ->
    receive
        {chan, MM, {msg, Msg, from, User}} ->
            io:format("[controller ~p] Message from ~p: ~p~n", [MM, User, Msg]),
            chat_server ! {mm, MM, {msg, Msg, from, User}},
            loop(MM, User);
        {'EXIT', _Pid, Reason} ->
            io:format("[controller ~p] Exiting: ~p~n", [MM, Reason]),
            chat_server ! {mm, MM, {logout, User}};
        X ->
            io:format("[controller ~p] Received: ~p~n", [MM, X]),
            loop(MM, User)
    end.
