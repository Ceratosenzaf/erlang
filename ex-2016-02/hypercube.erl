-module(hypercube).
-export([create/0, hamilton/2]).

gray(0) -> [""];
gray(N) -> ["0" ++ X || X <- gray(N-1)] ++ ["1" ++ X || X <- gray(N-1)].

equal_chars([], []) -> 0;
equal_chars([A | T1], [A | T2]) -> equal_chars(T1, T2) + 1;
equal_chars([_ | T1], [_ | T2]) -> equal_chars(T1, T2).

is_neighbor(A, B) -> equal_chars(A, B) == 3.

get_neighbors(A, Corners) -> lists:filter(fun ({B, _}) -> is_neighbor(A, B) end, Corners).

create() ->
    Names = gray(4),
    Corners = [{X, spawn(fun() -> corner:start(X) end)} || X <- Names],
    lists:foreach(fun ({Name, Pid}) ->  Pid ! {neighbors, get_neighbors(Name, Corners)} end, Corners),
    {_, First} = lists:keyfind("0000", 1, Corners),
    register(first_corner, First),
    ok.

hamilton(M, P) ->
  first_corner ! {msg, M, path, P},
  ok.
