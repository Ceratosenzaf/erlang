-module(lab2_3).
-export([start/1, to_slave/2]).

start(N) ->
  Pid = spawn(
    fun() -> 
      process_flag(trap_exit, true),
      master_loop([])
    end
  ),
  register(master, Pid),
  master ! {start_slaves, N},
  true.

to_slave(M, N) ->
  master ! {M, N}.

start_slave(X) -> spawn_link(fun() -> slave_loop(X) end).

index_of(_, []) -> -1;
index_of(E, [E | _]) -> 0;
index_of(E, [_ | T]) -> 1 + index_of(E, T).

master_loop(L) -> 
  receive
    {start_slaves, N} when N >= 1 ->
      L1 = [start_slave(X) || X <- lists:seq(1, N)],
      master_loop(L1);
    {start_slaves, N} ->
      io:format("Invalid number of slaves: ~p~n", [N]),
      master_loop(L);
    {M, N} when N >= 1 andalso N =< length(L) -> 
      S = lists:nth(N, L),
      S ! M,
      master_loop(L);
    {_, N} -> 
      io:format("Invalid slave index: ~p~n", [N]),
      master_loop(L);
    {'EXIT', Pid, Why} ->
      case index_of(Pid, L) of
        -1 -> 
          io:format("Unknown dying slave ~p: ~p~n", [Pid, Why]);
        I -> 
          io:format("Master restarting dead slave ~p~n", [I+1]),
          L1 = lists:sublist(L,I) ++ [start_slave(I+1)] ++ lists:nthtail(I+1,L),
          master_loop(L1)
      end,
      master_loop(L);
    M -> 
      io:format("Master got message ~p~n", [M]),
      master_loop(L)
  end.

slave_loop(X) ->
  receive
    die -> 
      io:format("Slave ~p about to die~n", [X]),
      exit(die);
    M -> 
      io:format("Slave ~p got message ~p~n", [X, M]),
      slave_loop(X)
  end.