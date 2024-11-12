-module(client).
-export([start/1]).

start(User) ->
  case lib_chan:connect("localhost", 12340, chat, "password123", notUsed) of
    {ok, Pid} ->  io:format("Successfully connected~n"), put(server, Pid), put(chat_user, User);
    {error, Why} -> io:format("Failed to connect: ~p~n", [Why])
  end.

send_message(Msg) -> get(server) ! {msg, Msg, from, get(User)}.