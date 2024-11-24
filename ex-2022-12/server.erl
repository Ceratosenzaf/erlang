-module(server).
-export([start/0]).

start() ->
    group_leader(whereis(user), self()),
    io:format("[server] starting~n"),
    loop(unknown, unknown, 0, 0, none, none).

stop_and_loop(MM1, MM2) ->
    MM1 ! {stop},
    MM2 ! {stop},
    loop(unknown, unknown, 0, 0, none, none).

loop(MM1, MM2, MM1Len, MM2Len, MM1C, MM2C) ->
    receive
        {msg, start, from, {N, Pid}} ->
            io:format("[server] starting message from: ~p~n", [N]),
            if
                (N == mm1 andalso MM2 /= unknown) -> MM2 ! {next};
                (N == mm2 andalso MM1 /= unknown) -> MM1 ! {next};
                true -> ok
            end,
            case N of
                mm1 -> loop(Pid, MM2, 0, 0, none, none);
                mm2 -> loop(MM1, Pid, 0, 0, none, none)
            end;
        {msg, stop, from, _} ->
            io:format("[server] palindrome~n"),
            stop_and_loop(MM1, MM2);
        {msg, X, from, {N, _}} ->
            io:format("[server] received message: ~p from: ~p~n", [X, N]),
            case N of
                mm1 ->
                    if
                        MM2Len /= MM1Len andalso X /= MM2C ->
                            io:format("[server] not palindrome~n"),
                            stop_and_loop(MM1, MM2);
                        true ->
                            MM2 ! {next},
                            loop(MM1, MM2, MM1Len + 1, MM2Len, X, MM2C)
                    end;
                mm2 ->
                    if
                        MM2Len /= MM1Len andalso X /= MM1C ->
                            io:format("[server] not palindrome~n"),
                            stop_and_loop(MM1, MM2);
                        true ->
                            MM1 ! {next},
                            loop(MM1, MM2, MM1Len, MM2Len + 1, MM1C, X)
                    end
            end;
        {close} ->
            io:format("[server] closing~n");
        X ->
            io:format("[server] WARNING - received: ~p~n", [X]),
            loop(MM1, MM2, MM1Len, MM2Len, MM1C, MM2C)
    end.
