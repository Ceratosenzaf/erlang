-module(client).
-export([login/1, connect/1, msg/1, disconnect/0, logout/0, list_groups/0, list_users/0]).

get_server_node() ->
    {ok, Host} = inet:gethostname(),
    Node = "server@" ++ Host,
    list_to_atom(Node).

send_to_server(Msg) ->
    Node = get_server_node(),
    {server, Node} ! Msg.

login(U) ->
    erlang:set_cookie(node(), my_cookie),
    register(client, spawn_link(fun() -> loop({U, self()}) end)),
    client ! {login}.

logout() ->
    client ! {logout},
    unregister(client).
connect(G) -> client ! {connect, G}.
disconnect() -> client ! {disconnect}.
msg(M) -> client ! {msg, M}.
list_groups() -> client ! {list_groups}.
list_users() -> client ! {list_users}.

loop(U) ->
    receive
        {login} ->
            send_to_server({login, U}),
            receive
                {ack} ->
                    io:format("[client] Successfully logged in~n");
                {error, X} ->
                    io:format("[client] Error logging in: ~p~n", [X]),
                    exit(X);
                X ->
                    io:format("[client] WARNING - received: ~p~n", [X])
            after 1000 ->
                io:format("[client] Error logging in: timeout~n"),
                exit(timeout)
            end,
            loop(U);
        {logout} ->
            send_to_server({logout, U}),
            loop(U);
        {connect, G} ->
            send_to_server({connect, G, U}),
            loop(U);
        {disconnect} ->
            send_to_server({disconnect, U}),
            loop(U);
        {msg, M} ->
            send_to_server({msg, M, U}),
            loop(U);
        {list_groups} ->
            send_to_server({list_groups, U}),
            receive
                X -> io:format("[client] ~p~n", [X])
            end,
            loop(U);
        {list_users} ->
            send_to_server({list_users, U}),
            receive
                X -> io:format("[client] ~p~n", [X])
            end,
            loop(U);
        {connected, U} ->
            io:format("[client] You connected~n"),
            loop(U);
        {connected, {X, _}} ->
            io:format("[client] ~p connected~n", [X]),
            loop(U);
        {disconnected, U} ->
            io:format("[client] You disconnected~n"),
            loop(U);
        {disconnected, {X, _}} ->
            io:format("[client] ~p disconnected~n", [X]),
            loop(U);
        {msg, M, from, U} ->
            io:format("[client] You: ~p~n", [M]),
            loop(U);
        {msg, M, from, {X, _}} ->
            io:format("[client] ~p: ~p~n", [X, M]),
            loop(U);
        X ->
            io:format("[client] WARNING - received: ~p~n", [X]),
            loop(U)
    end.
