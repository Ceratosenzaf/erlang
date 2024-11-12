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
        {mm, MM, {login}} ->
            io:format("[server] Controller ~p logged in~n", [MM]),
            loop([MM | Controllers]);
        {mm, MM, {msg, Msg, from, User}} ->
            io:format("[server] Message from ~p: ~p~n", [User, Msg]),
            lists:foreach(
                fun(C) ->
                    % TODO: fix this
                    lib_chan_mm:send(C, {relay, Msg, from, User})
                end,
                lists:delete(MM, Controllers)
            ),
            loop(Controllers);
        {'EXIT', MM, Reason} ->
            io:format("[server] Controller ~p closing: ~p~n", [MM, Reason]),
            loop(lists:delete(MM, Controllers));
        X ->
            io:format("[server] Received: ~p~n", [X]),
            loop(Controllers)
    end.
