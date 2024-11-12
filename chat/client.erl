-module(client).
-export([connect/1, send_message/1]).

connect(User) ->
    case lib_chan:connect("localhost", 12340, chat, "password123", []) of
        {ok, MM} ->
            io:format("[client] Successfully connected~n"),
            put(chat_mm, MM),
            put(chat_user, User),
            ok;
        {error, Why} ->
            io:format("[client] Failed to connect: ~p~n", [Why]),
            sleep(1000),
            io:format("[client] Retrying...~n"),
            connect(User)
    end.

sleep(T) ->
    receive
    after T -> ok
    end.

send_message(Msg) -> lib_chan_mm:send(get(chat_mm), {msg, Msg, from, get(chat_user)}).
