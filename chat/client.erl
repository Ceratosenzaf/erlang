-module(client).
-export([connect/1, send_message/1]).

connect(User) ->
    case lib_chan:connect("localhost", 12340, chat, "password123", User) of
        {ok, MM} ->
            io:format("[client] Successfully connected~n"),
            put(chat_mm, MM),
            put(chat_user, User),
            spawn(fun() ->
                put(chat_user, User),
                lib_chan_mm:controller(MM, self()),
                loop(MM)
            end),
            ok;
        {error, Why} ->
            io:format("[client] Failed to connect: ~p~n", [Why]),
            io:format("[client] Retrying in 5 sec...~n"),
            sleep(5000),
            connect(User)
    end.

sleep(T) ->
    receive
    after T -> ok
    end.

send_message(Msg) ->
    lib_chan_mm:send(get(chat_mm), {msg, Msg, from, get(chat_user)}),
    io:format("[client] You: ~p~n", [Msg]).

loop(MM) ->
    receive
        {chan, MM, {msg, Msg, from, User}} ->
            io:format("[client] @~p: ~p~n", [User, Msg]),
            loop(MM);
        {chan, MM, {login, User}} ->
            io:format("[client] @~p connected~n", [User]),
            loop(MM);
        {chan, MM, {logout, User}} ->
            io:format("[client] @~p disconnected~n", [User]),
            loop(MM);
        {chan_closed, MM} ->
            io:format("[client] Connection lost~n", []),
            connect(get(chat_user));
        X ->
            io:format("[client] Received: ~p~n", [X]),
            loop(MM)
    end.
