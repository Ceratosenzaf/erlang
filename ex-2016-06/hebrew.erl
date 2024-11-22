-module(hebrew).
-export([start/3]).

start(N, Step, Master) -> loop(N, Step, Master).

get_next([], _) -> not_found;
get_next([E, X | _], E) -> X;
get_next([_ | T], E) -> get_next(T, E).

get_next_in_ring(R) ->
    case get_next(R, self()) of
        not_found -> lists:nth(1, R);
        X -> X
    end.

loop(N, Step, Master) ->
    receive
        {kill, _, remaining, [_]} ->
            io:format("[hebrew ~p] last one standing~n", [N]),
            Master ! {last, N};
        {kill, Step, remaining, H} ->
            io:format("[hebrew ~p] about to die~n", [N]),
            Next = get_next_in_ring(H),
            Rest = lists:delete(self(), H),
            Next ! {kill, 1, remaining, Rest};
        {kill, I, remaining, H} ->
            io:format("[hebrew ~p] still alive (~p off) with other ~p hebrews~n", [N, Step - I, length(H)]),
            Next = get_next_in_ring(H),
            Next ! {kill, I + 1, remaining, H},
            loop(N, Step, Master);
        X -> 
            io:format("[hebrew ~p] Warning - received ~p~n", [N, X]),
            loop(N, Step, Master)
    end.