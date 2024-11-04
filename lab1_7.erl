-module(lab1_7).
-export([start/3, loop/5]).

start(M, N, Message) -> 
  Pid = spawn(lab1_7, loop, [M, N, self(), Message, self()]),
  Pid ! {first, Pid},
  Pid ! spawn.

loop(M, N, Next, Message, First) ->
  receive
    stop -> 
      io:format("(~p) Stopping~n", [self()]),
      Next ! stop;
    {first, V} ->
      io:format("(~p) Received first: ~p~n", [self(), V]),
      loop(M, N, Next, Message, V);
    spawn ->
      if
        N > 1 ->
          io:format("(~p) Spawning~n", [self()]),
          Pid = spawn(lab1_7, loop, [M, (N-1), self(), Message, First]),
          Pid ! spawn,
          loop(M, N, Pid, Message, First);
        true ->
          io:format("(~p) Sending first message~n", [self()]),
          First ! Message,
          loop(M, N, First, Message, First)
      end;
    Message -> 
      if
        M >= 1 -> 
          Next ! Message,
          io:format("(~p) Received: ~p~n", [self(), Message]),
          loop((M-1), N, Next, Message, First);
        true ->
          io:format("(~p) Stopping~n", [self()]),
          Next ! stop
      end;
    Other -> 
      io:format("(~p) I don't know how to react to the message ~p~n", [self(), Other]),
      loop(M, N, Next, Message, First)
  after
    1000 -> 
      io:format("(~p) Timeout~n", [self()]),
      loop(M, N, Next, Message, First)
  end.