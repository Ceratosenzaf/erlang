-module(lab2_2).
-export([start/0, store/2, lookup/1]).

start() -> 
  S = self(),
  Pid = spawn(
    fun() -> 
      register(my_parent, S),
      loop([])
    end
  ),
  register(my_store, Pid).

store(K, V) ->
  my_store ! {store, {K, V}},
  receive
    {ok} -> ok;
    E -> E
  end.

lookup(K) ->
  my_store ! {lookup, {K}},
  receive
    {ok, V} -> V;
    E -> E
  end.

loop(L) -> 
  receive
    {store, {K, V}} ->
      io:format("store ~p: ~p~n", [K, V]),
      case find(K, L) of
        {K, V} -> my_parent ! already_registered, loop(L);
        _ -> my_parent ! {ok}, loop([{K, V}|L])
      end;
    {lookup, {K}} ->
      io:format("lookup ~p~n", [K]),
      case find(K, L) of
        {K, V} -> my_parent ! {ok, V};
        _ -> my_parent ! undefined
      end,
      loop(L);
    X -> 
      io:format("received ~p~n", [X])
  end.

find(_, []) -> undefined;
find(K, [{K, V}|_]) -> {K, V};
find(K, [_|T]) -> find(K, T).
