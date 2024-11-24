-module(client).
-export([start/0, close/0, is_palindrome/1, divide_list/1]).

get_node(N, Host) ->
    Node = atom_to_list(N) ++ "@" ++ Host,
    list_to_atom(Node).

start() ->
    group_leader(whereis(user), self()),
    {ok, Host} = inet:gethostname(),
    io:format("[client] starting~n"),
    Server = spawn_link(get_node(server, Host), server, start, []),
    MM1 = spawn_link(get_node(mm1, Host), mm, start, [mm1, Server]),
    MM2 = spawn_link(get_node(mm2, Host), mm, start, [mm2, Server]),
    register(client, spawn_link(fun() -> loop(MM1, MM2) end)),
    ok.

close() ->
    client ! {close},
    ok.

is_palindrome(X) -> client ! {msg, X}.

loop(MM1, MM2) ->
    receive
        {msg, X} ->
            io:format("[client] received message: ~p~n", [X]),
            {FirstHalf, SecondHalfReversed} = divide_list(X),
            MM1 ! {msg, FirstHalf},
            MM2 ! {msg, SecondHalfReversed},
            loop(MM1, MM2);
        {close} ->
            io:format("[client] closing~n"),
            MM1 ! {close},
            MM2 ! {close};
        X ->
            io:format("[client] WARNING - received: ~p~n", [X]),
            loop(MM1, MM2)
    end.

divide_list(X) -> divide_list(X, length(X) / 2, 0, [], []).
divide_list([], _, _, Fst, Snd) -> {lists:reverse(Fst), Snd};
divide_list([H | T], M, I, Fst, Snd) when I < M -> divide_list(T, M, I + 1, [H | Fst], Snd);
divide_list([H | T], M, I, Fst, Snd) -> divide_list(T, M, I + 1, Fst, [H | Snd]).
