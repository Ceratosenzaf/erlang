-module(lab1_6).
-export([start/3, loop/3]).

start(M, N, Message) -> 
  Pids = [spawn(lab1_6, loop, [M, self(), Message]) || _ <- lists:seq(1, N)],
  lists:zipwith(fun(Pid, NextPid) -> Pid ! {next, NextPid} end, Pids, tl(Pids) ++ [hd(Pids)]),
  hd(Pids) ! Message.

loop(N, Next, Message) -> 
  receive
    {next, NextPid} -> 
      io:format("(~p) Received next pid: ~p~n", [self(), NextPid]),
      loop(N, NextPid, Message);
    stop -> 
      io:format("(~p) Stopping~n", [self()]),
      Next ! stop;
    Message -> 
      if
        N >= 1 -> 
          Next ! Message,
          io:format("(~p) Received: ~p~n", [self(), Message]),
          loop(N-1, Next, Message);
        true ->
          io:format("(~p) Stopping~n", [self()]),
          Next ! stop
      end;
    Other -> 
      io:format("(~p) I don't know how to react to the message ~p~n", [self(), Other]),
      loop(N, Next, Message)
  after
    1000 -> 
      io:format("(~p) Timeout~n", [self()]),
      loop(N, Next, Message)
  end.