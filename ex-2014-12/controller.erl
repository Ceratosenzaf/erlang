-module(controller).
-export([start/1]).

start(N) ->
  put(sieve_parent, self())
  FirstSieve = spawn_sieves(primes),
  register(firstSieve, FirstSieve),
  loop(N).

primes(N) when N>1 ->
  [
    X || X <- lists:seq(2,N),
    (
      length(
        [
          Y || Y <- lists:seq(2, trunc(math:sqrt(X))),
          ((X rem Y) == 0)
        ]
      ) == 0
    )
  ];
primes(_) -> [].

spawn_sieves([]) -> ok;
spawn_sieves([H | T]) ->
  P = get(sieve_parent),
  Pid = spawn_link(
    fun() ->
      sieve:loop(H, unknown, P)
    end
  ),
  P ! {next, Pid},
  put(sieve_parent, Pid),
  spawn_sieves(N-1),
  Pid.

loop(M) ->
  receive
    {quit} ->
      io:format("[controller] I'm closing~n"),
      exit(quit);
    {new, N, Client} when N >= math:sqrt(M) ->
      io:format("[controller] you asked for ~p, which is too big~n", [N]),
      Client ! {reslut, "number too big"},
      loop(M);
    {new, N, Client} ->
      io:format("[controller] you asked for ~p~n", [N]),
      firstSieve ! {new, N},
      receive
        {res, R} ->
          io:format("[controller] received result ~p for ~p~n", [R, N]),
          Client ! {result, R};
        X ->
          io:format("[controller] received ~p~n", [X])
      end,
      loop(M);
    X ->
      io:format("[controller] received ~p~n", [X]),
      loop(M)
  end.