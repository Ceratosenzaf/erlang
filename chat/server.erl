-module(server).
-export([start/0]).

start() ->
    spawn(fun() ->
        process_flag(trap_exit, true),
        register(chat_server, self()),
        io:format("[server] started at: ~p~n", [self()]),
        E = (catch loop([])),
        io:format("[server] terminated with: ~p~n", [E])
    end),
    lib_chan:start_server("chat.conf").

loop(Controllers) ->
    receive
        {mm, MM, {login, User}} ->
            io:format("[server] User @~p logged in~n", [User]),
            broadcast({login, User}, lists:delete(MM, Controllers)),
            loop([MM | Controllers]);
        {mm, MM, {msg, Msg, from, User}} ->
            io:format("[server] Message from @~p: ~p~n", [User, Msg]),
            broadcast({msg, Msg, from, User}, lists:delete(MM, Controllers)),
            loop(Controllers);
        {mm, MM, {logout, User}} ->
            io:format("[server] User @~p logged out~n", [User]),
            broadcast({logout, User}, lists:delete(MM, Controllers)),
            loop(lists:delete(MM, Controllers));
        X ->
            io:format("[server] Received: ~p~n", [X]),
            loop(Controllers)
    end.

broadcast(Msg, Controllers) ->
    lists:foreach(
        fun(C) ->
            lib_chan_mm:send(C, Msg)
        end,
        Controllers
    ).
