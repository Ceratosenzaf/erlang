-module(sieve).
-export([loop/3]).

loop(Value, Next, Parent) ->
  receive
    {pass, N} ->
      io:format("[sieve ~p] checking ~p: ~p~n", [Value, N, N rem Value]),
      case N rem Value of
        0 -> Parent ! {res, false};
        _ -> 
          if
            Next =/= Parent -> Next ! {pass, N};
            true -> Next ! {res, true}
          end
      end,
      loop(Value, Next, Parent);
    {res, R} ->
      io:format("[sieve ~p] received result ~p~n", [Value, R]),
      Parent ! {result, R},
      loop(Value, Next, Parent);
    {next, N} ->
      io:format("[sieve ~p] received next ~p~n", [Value, N]),
      loop(Value, N, Parent);
    X ->
      io:format("[sieve ~p] received ~p~n", [Value, X]),
      loop(Value, Next, Parent)
  end.