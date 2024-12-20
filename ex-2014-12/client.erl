-module(client).
-export([set_controller_pid/1, is_prime/1, close/0]).

set_controller_pid(Pid) -> put(controller, Pid).

is_prime(N) ->
    get(controller) ! {new, N, self()},
    receive
        {result, R} when is_list(R) ->
            io:format("[client] ~p~n", [R]);
        {result, R} ->
            io:format("[client] is ~p prime? ~p~n", [N, R]);
        X ->
            io:format("[client] received ~p~n", [X])
    end.

close() ->
    get(controller) ! {quit},
    io:format("[client] the service is closed~n").
