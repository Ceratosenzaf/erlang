-module(joseph).
-export([joseph/2]).

joseph(People, Step) ->
    P = self(),
    H =  [spawn(fun() -> hebrew:start(X, Step, P) end) || X <- lists:seq(1, People)],
    Fst = lists:nth(1, H),
    Fst ! {kill, 1, remaining, H},
    receive
        {last, N} -> io:format("[joseph] ~p survived~n", [N]);
        X -> io:format("[joseph] Warning - received ~p~n", [X])
    end.
