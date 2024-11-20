-module(ring).
-export([start/2, send_message/1, send_message/2, stop/0]).

start(N, Functions) when N >= 1 andalso length(Functions) == N ->
    Pids = start_all(Functions),
    connect(Pids),
    register(first_node, lists:nth(1, Pids)).

start_all(L) ->
    PrintNode = spawn(fun() -> node:start_print_node() end),
    [
        spawn(fun() -> node:start(X, PrintNode) end)
     || X <- L
    ].

connect([H | T]) ->
    lists:zipwith(fun(Pid, NextPid) -> Pid ! {next, NextPid} end, [H | T], T ++ [H]).

send_message(X) -> first_node ! {data, X, 1}.
send_message(X, N) when N > 0 -> first_node ! {data, X, N}.
stop() -> first_node ! {stop}.
