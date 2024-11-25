-module(hebrew).
-export([start/3]).

start(N, Step, Master) ->
    receive
        {hebrews, H} ->
            process_flag(trap_exit, true),
            lists:foreach(fun(X) -> link(X) end, H),
            loop(N, Step, Master, H);
        X ->
            io:format("[hebrew ~p] ERROR - received ~p~n", [N, X])
    end.

loop(N, _, Master, [_]) ->
    io:format("[hebrew ~p] last one standing~n", [N]),
    Master ! {last, N};
loop(N, Step, Master, H) ->
    Next = get_next_in_ring(H),
    Prev = get_prev_in_ring(H),
    receive
        {kill, Step} ->
            io:format("[hebrew ~p] about to die~n", [N]),
            exit(die);
        {kill, I} ->
            io:format("[hebrew ~p] still alive (~p off) with other ~p hebrews~n", [
                N, Step - I, length(H)
            ]),
            Next ! {kill, I + 1},
            loop(N, Step, Master, H);
        {'EXIT', Prev, _} ->
            io:format("[hebrew ~p] removing dead hebrew (predecessor): ~p~n", [N, Prev]),
            self() ! {kill, 1},
            loop(N, Step, Master, lists:delete(Prev, H));
        {'EXIT', Pid, _} ->
            io:format("[hebrew ~p] removing dead hebrew: ~p~n", [N, Pid]),
            loop(N, Step, Master, lists:delete(Pid, H));
        X ->
            io:format("[hebrew ~p] Warning - received ~p~n", [N, X]),
            loop(N, Step, Master, H)
    end.

get_next_in_ring(R) ->
    case get_next(R, self()) of
        not_found -> lists:nth(1, R);
        X -> X
    end.
get_next([], _) -> not_found;
get_next([E, X | _], E) -> X;
get_next([_ | T], E) -> get_next(T, E).

get_prev_in_ring(R) ->
    case get_prev(R, self()) of
        not_found -> lists:last(R);
        X -> X
    end.
get_prev([], _) -> not_found;
get_prev([X, E | _], E) -> X;
get_prev([_ | T], E) -> get_prev(T, E).
