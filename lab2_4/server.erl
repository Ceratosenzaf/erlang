-module(server).
-export([start/0]).

start() ->
  spawn(fun() ->
    process_flag(trap_exit, true),
    register(server, self()),
    io:format("[server] started at: ~p~n", [self()]),
    E = (catch loop()),
    io:format("[server] terminated with: ~p~n", [E])
  end),
  lib_chan:start_server("lab2_4.conf").

loop() ->
  receive
    {chan, MM, {reverse, S}} when is_list(S) -> 
      io:format("[server] reversing ~p~n", [S]),
      Reversed = reverse_string(S),
      lib_chan_mm:send(MM, {reversed, Reversed}),
      loop();
    X -> 
      io:format("[server] received unknown ~p~n", [X]), 
      loop()
  end.

reverse_string(S) ->
  L = length(S),
  N = L div 10,
  R = L rem 10,
  split_string(S, N, R, 0),
  receive_all([]).

receive_all(L) ->
  if 
    length(L) == 10 -> 
      io:format("[server] received all reversed strings:~p~n", [L]),
      Sorted = lists:sort(fun({I1, _}, {I2, _}) -> I1 > I2 end, L),
      Concatenated = lists:foldl(fun({_I, R}, Acc) -> Acc ++ R end, [], Sorted),
      io:format("[server] concatenated reversed strings: ~p~n", [Concatenated]),
      Concatenated;
    true -> 
      receive
        {reversed, I, R} -> 
          io:format("[server] received reversed string at ~p: ~p~n", [I, R]),
          receive_all([{I, R} | L]);
        X -> 
          io:format("[server] received unknown ~p~n", [X]), 
          receive_all(L)
      end
  end.

split_string(S, N, R, I) when I < 10 ->
  {Substring, Rest} = if I < R ->
                          manual_split(N + 1, S, []);
                      true ->
                          manual_split(N, S, [])
                      end,
  start_slave(Substring, I),
  split_string(Rest, N, R, I + 1);
split_string(_, _, _, _) -> ok.

manual_split(0, Rest, Acc) -> {lists:reverse(Acc), Rest};
manual_split(_, [], Acc) -> {lists:reverse(Acc), []};
manual_split(N, [H | T], Acc) -> manual_split(N - 1, T, [H | Acc]).

start_slave(S, I) ->
  P = self(),
  spawn(
    fun() -> 
      R = lists:reverse(S),
      P ! {reversed, I, R}
    end
  ).
