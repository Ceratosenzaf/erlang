-module(client).
-export([connect/0, reverse/1]).

connect() ->
  case lib_chan:connect("localhost", 12340, reverse_string, "password123", []) of
    {ok, MM} -> 
      put(mm, MM),
      spawn(
        fun() ->
          put(mm, MM),
          loop(MM)
        end
      ),
      ok;
    {error, Why} ->
      io:format("[client] failed to connect: ~p~n", [Why]),
      io:format("[client] retrying in 5 seconds...~n"),
      sleep(5000),
      connect()
  end.

sleep(T) -> receive after T -> true end.

reverse(S) -> lib_chan_mm:send(get(mm), {reverse, S}).

loop(MM) ->
  receive
    {chan, MM, {reversed, S}} ->
      io:format("[client] received reversed string: ~p~n", [S]),
      loop(MM);
    X -> 
      io:format("[client] received unknown ~p~n", [X]),
      loop(MM)
  end.