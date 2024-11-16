-module(lab2_5).
-export([set_cookie/0, connect/1, connect/2, disconnect/0, send/1, peers/0]).

set_cookie() -> erlang:set_cookie(node(), 'cookie').

connect(User) -> connect(User, undefined).
connect(User, Peer) ->
    set_cookie(),
    Pid = spawn(
        fun() ->
            case Peer of
                undefined -> ok;
                Pid -> Pid ! {login, {User, self()}}
            end,
            process_flag(trap_exit, true),
            put(user, User),
            loop([])
        end
    ),
    put(user, User),
    register(client, Pid),
    ok.

disconnect() ->
    client ! {logout},
    ok.

send(Msg) ->
    client ! {msg, Msg},
    ok.

peers() ->
    client ! {peers},
    ok.

loop(Peers) ->
    receive
        {login, {User, Pid}} ->
            io:format("[client]: ~p logged in~n", [User]),
            Pid ! {login_ack, Peers, {get(user), self()}},
            link(Pid),
            lists:foreach(fun({_, P}) -> P ! {p2p, login, {User, Pid}} end, Peers),
            loop([{User, Pid} | Peers]);
        {login_ack, P1, Peer} ->
            io:format("[client] You logged in~n", []),
            loop([Peer | P1]);
        {logout} ->
            io:format("[client]: You logged out~n", []),
            lists:foreach(fun({_, P}) -> P ! {p2p, logout, {get(user), self()}} end, Peers);
        {msg, Msg} ->
            io:format("[client] You: ~p~n", [Msg]),
            lists:foreach(fun({_, P}) -> P ! {p2p, msg, Msg, {get(user), self()}} end, Peers),
            loop(Peers);
        {peers} ->
            io:format("[client] Peers: ~p~n", [Peers]),
            loop(Peers);
        {p2p, login, {User, Pid}} ->
            io:format("[client]: ~p logged in~n", [User]),
            link(Pid),
            loop([{User, Pid} | Peers]);
        {p2p, logout, {User, Pid}} ->
            io:format("[client]: ~p logged out~n", [User]),
            loop(lists:delete({User, Pid}, Peers));
        {p2p, msg, Msg, {User, _Pid}} ->
            io:format("[client] ~p: ~p~n", [User, Msg]),
            loop(Peers);
        {'EXIT', Pid, _Why} ->
            {User, Pid} = lists:keyfind(Pid, 2, Peers),
            io:format("[client] ~p logged out~n", [User]),
            loop(lists:keydelete(Pid, 2, Peers));
        X ->
            io:format("[client] received ~p~n", [X]),
            loop(Peers)
    end.
