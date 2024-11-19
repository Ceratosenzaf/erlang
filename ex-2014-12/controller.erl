-module(controller).
-export([start/1]).

start(N) ->
    put(controller, self()),
    put(sieve_parent, self()),
    FirstSieve = spawn_sieves(primes(N)),
    register(firstSieve, FirstSieve),
    register(controller, self()),
    loop(N).

primes(N) when N > 1 ->
    [
        X
     || X <- lists:seq(2, N),
        (length(
            [
                Y
             || Y <- lists:seq(2, trunc(math:sqrt(X))),
                ((X rem Y) == 0)
            ]
        ) == 0)
    ];
primes(_) ->
    [].

spawn_sieves([]) ->
    ok;
spawn_sieves([H]) ->
    P = get(sieve_parent),
    spawn_link(
        fun() ->
            sieve:loop(H, get(controller), P)
        end
    ),
    spawn_sieves([]);
spawn_sieves([H | T]) ->
    P = get(sieve_parent),
    Pid = spawn_link(
        fun() ->
            sieve:loop(H, unknown, P)
        end
    ),
    P ! {next, Pid},
    put(sieve_parent, Pid),
    spawn_sieves(T),
    Pid.

loop(M) ->
    receive
        {quit} ->
            io:format("[controller] I'm closing~n"),
            exit(quit);
        {new, N, Client} when N < 2 ->
            io:format("[controller] you asked for ~p, which is too small~n", [N]),
            Client ! {result, "number too small"},
            loop(M);
        {new, N, Client} ->
            case N > math:pow(M, 2) of
                true ->
                    io:format("[controller] you asked for ~p, which is too big~n", [N]),
                    Client ! {result, "number too big"};
                false ->
                    io:format("[controller] you asked for ~p~n", [N]),
                    firstSieve ! {pass, N},
                    receive
                        {res, R} ->
                            io:format("[controller] received result ~p for ~p~n", [R, N]),
                            Client ! {result, R};
                        X ->
                            io:format("[controller] received ~p~n", [X])
                    end
            end,
            loop(M);
        X ->
            io:format("[controller] received ~p~n", [X]),
            loop(M)
    end.
