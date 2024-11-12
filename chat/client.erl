-module(client).
-export([connect/1, send_message/1]).

connect(User) ->
    case lib_chan:connect("localhost", 12340, chat, "password123", []) of
        {ok, MM} ->
            io:format("[client] Successfully connected~n"),
            put(chat_mm, MM),
            put(chat_user, User),
            spawn(fun() ->
                lib_chan_mm:controller(MM, self()),
                loop(MM)
            end),
            ok;
        {error, Why} ->
            io:format("[client] Failed to connect: ~p~n", [Why]),
            io:format("[client] Retrying in 1 sec...~n"),
            sleep(1000),
            connect(User)
    end.

sleep(T) ->
    receive
    after T -> ok
    end.

send_message(Msg) -> lib_chan_mm:send(get(chat_mm), {msg, Msg, from, get(chat_user)}).

loop(MM) ->
    receive
        {chan, MM, {msg, Msg, from, User}} ->
            io:format("[client] Message from ~p: ~p~n", [User, Msg]),
            loop(MM);
        X ->
            io:format("[client] Received: ~p~n", [X]),
            loop(MM)
    end.
