-module(server).
-export([start/0]).

start() ->
  lib_chan:start_server("chat.conf"),
  spawn(fun() -> loop() end).

loop() -> 
  receive
    X -> io:format("[server] received: ~p~n", [X])
  end.

  