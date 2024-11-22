-module(tempsys).
-export([start/0]).

fromC(X) -> X.
fromDe(X) -> 100-X*2/3.
fromF(X) -> (X-32)*5/9.
fromK(X) -> X-273.15.
fromN(X) -> X*100/33.
fromR(X) -> (X-491.67)*5/9.
fromRe(X) -> X*5/4.
fromRo(X) -> (X-7.5)*40/21.

toC(X) -> X.
toDe(X) -> (100-X)*3/2.
toF(X) -> X*9/5+32.
toK(X) -> X+273.15.
toN(X) -> X*33/100.
toR(X) -> X*9/5+491.67.
toRe(X) -> X*4/5.
toRo(X) -> X*21/40+7.5.

start() ->
    lists:foreach(
        fun({U, FromC, ToC}) ->
            Pid = spawn_link(fun() -> converter:start(U, FromC, ToC) end),
            register(U, Pid)
        end,
        [
            {'C',  fun toC/1,  fun fromC/1 },
            {'De', fun toDe/1, fun fromDe/1},
            {'F',  fun toF/1,  fun fromF/1 },
            {'K',  fun toK/1,  fun fromK/1 },
            {'N',  fun toN/1,  fun fromN/1 },
            {'R',  fun toR/1,  fun fromR/1 },
            {'Re', fun toRe/1, fun fromRe/1},
            {'Ro', fun toRo/1, fun fromRo/1}
        ]
    ).
