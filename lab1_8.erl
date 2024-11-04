-module(lab1_8).
-export([start/0, print/1, stop/0]).

start() -> 
  Pid = spawn(lab1_8, loop, []),
  register(server, Pid),
  ok.

print(M) ->
  server ! {message, M},
  ok.

stop() ->
  server ! {stop},
  ok.

loop() ->
  receive
    {message, M} ->
      io:format("~p~n", [M]),
      loop();
    {stop} -> 
      io:format("stopping ~n", [])
  end.