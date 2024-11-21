-module(corner).
-export([start/1]).

start(Name) ->
    io:format("[corner ~p] starting~n", [Name]),
    receive
        {neighbors, N} ->
            io:format("[corner ~p] received neighbors: ~p~n", [Name, N]),
            loop(Name, N);
        X -> io:format("[corner ~p] ERROR - received: ~p~n", [Name, X])
    end.

get_neighbor_pid(_, []) -> {error, not_found};
get_neighbor_pid(Name, [{Name, Pid} | _]) -> {ok, Pid};
get_neighbor_pid(Name, [_ | T]) -> get_neighbor_pid(Name, T).

loop(Name, Neighbors) ->
    receive
        {msg, M, path, [Name, Next | T]} ->
            io:format("[corner ~p] received message: ~p~n", [Name, M]),
            case get_neighbor_pid(Next, Neighbors) of
                {ok, Pid} -> Pid ! {msg, M, path, [Next | T]};
                {error, not_found} -> io:format("[corner ~p] invalid neighbor: ~p, actual neighbors: ~p~n", [Name, Next, Neighbors])
            end,
            loop(Name, Neighbors);
        {msg, M, path, [Name]} ->
            io:format("[corner ~p] received last message: ~p~n", [Name, M]),
            loop(Name, Neighbors);
        {msg, _, path, P} ->
            io:format("[corner ~p] received invalid path: ~p~n", [Name, P]),
            loop(Name, Neighbors);
        X ->
            io:format("[corner ~p] received: ~p~n", [Name, X]),
            loop(Name, Neighbors)
    end.