-module(controller).
-export([start/3]).

start(MM, _, _) -> 
  io:format("[controller] started~n"),
  loop(MM).

loop(MM) ->
  receive
    {chan, MM, {reverse, S}} ->
      server ! {chan, MM, {reverse, S}},
      loop(MM);
    X -> 
      io:format("[controller] received unknown ~p~n", [X]),
      loop(MM)
  end.