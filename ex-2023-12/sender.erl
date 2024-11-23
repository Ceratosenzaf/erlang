-module(sender).
-export([start/2, send_msg/1, quit/0, shutdown/0]).

start(N, Node) when N > 0 ->
    Pids = [spawn_link(switch, start, []) || _ <- lists:seq(1,N)],
    [P ! {next, N} || P <- Pids, N <- tl(Pids) ++ hd(Pids)],
    register(sender, spawn_link(fun() -> loop(hd(Pids)) end)),
    put(receiver_node, Node),
    ok.

send_msg(M) -> sender ! {msg, M}.
quit() -> sender ! {quit}.
shutdown() -> sender ! {shutdown}.

loop(S) ->
    receive
        {quit} ->
            io:format("[sender] quitting~n", []),
            lists:foreach(fun(P) -> P ! {quit} end, S);
        {shutdown} ->
            io:format("[sender] quitting~n", []),
            lists:foreach(fun(P) -> P ! {quit} end, S),
            {receiver, get(receiver_node)} ! {quit};
        {msg, X} ->
            io:format("[sender] received message: ~p~n", [X]),
            S ! {start, get_tokens(X)},
            loop(S);
        X ->
            io:format("[sender] WARNING - received: ~p~n", [X]),
            loop(S)
    end.