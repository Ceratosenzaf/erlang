-module(sender).
-export([start/2, send_msg/1, quit/0, shutdown/0]).

start(N, Node) when N > 0 ->
    Pids = [spawn_link(switch, start, [Node]) || _ <- lists:seq(1, N)],
    connect_ring(Pids),
    register(
        sender,
        spawn_link(fun() ->
            put(receiver_node, Node),
            loop(Pids)
        end)
    ),
    ok.

connect_ring(P) -> connect_to_next(P, tl(P) ++ [hd(P)]).
connect_to_next([Ph | Pt], [Nh | Nt]) ->
    Ph ! {next, Nh},
    connect_to_next(Pt, Nt);
connect_to_next([], []) ->
    ok.

send_msg(M) -> sender ! {msg, M}.
quit() -> sender ! {quit}.
shutdown() -> sender ! {shutdown}.

loop(S) ->
    receive
        {quit} ->
            io:format("[sender] quitting~n"),
            lists:foreach(fun(P) -> P ! {quit} end, S);
        {shutdown} ->
            io:format("[sender] quitting~n"),
            lists:foreach(fun(P) -> P ! {quit} end, S),
            {receiver, get(receiver_node)} ! {quit};
        {msg, X} ->
            io:format("[sender] received message: ~p~n", [X]),
            hd(S) ! {start, get_tokens(X)},
            loop(S);
        X ->
            io:format("[sender] WARNING - received: ~p~n", [X]),
            loop(S)
    end.

get_tokens(M) ->
    get_tokens(M, []).

get_tokens([], Acc) ->
    lists:reverse(Acc);
get_tokens(M, Acc) ->
    {Token, Rest} = take_token(M, []),
    get_tokens(Rest, [Token | Acc]).

take_token([], Acc) ->
    {lists:reverse(Acc), []};
take_token([$\s | Rest], Acc) ->
    {lists:reverse(Acc), Rest};
take_token([H | T], Acc) ->
    take_token(T, [H | Acc]).
