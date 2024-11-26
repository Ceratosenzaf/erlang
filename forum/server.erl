-module(server).
-export([start/0]).

start() ->
    io:format("[server] starting~n"),
    erlang:set_cookie(node(), my_cookie),
    register(server, self()),
    register(group_controller, spawn_link(group_controller, start, [])),
    loop([]).

loop(Users) ->
    receive
        {connect, G, U} ->
            io:format("[server] user ~p wants to connect to group: ~p~n", [U, G]),
            group_controller ! {connect, G, U},
            loop(Users);
        {disconnect, U} ->
            io:format("[server] user ~p wants to disconnect from its current group~n", [U]),
            group_controller ! {disconnect, U},
            loop(Users);
        {msg, M, U} ->
            io:format("[server] user ~p wants to send a message: ~p~n", [U, M]),
            group_controller ! {msg, M, U},
            loop(Users);
        {list_users, U} ->
            io:format("[server] user ~p requested users list~n", [U]),
            group_controller ! {list_users, U},
            loop(Users);
        {list_groups, U} ->
            io:format("[server] user ~p requested groups list~n", [U]),
            group_controller ! {list_groups, U},
            loop(Users);
        {login, {U, Pid}} ->
            case lists:keyfind(Pid, 2, Users) of
                {X, Pid} ->
                    io:format(
                        "[server] ~p (~p) attempted login, but is already logged in as ~p~n", [
                            U, Pid, X
                        ]
                    ),
                    Pid ! {error, already_logged_id},
                    loop(Users);
                false ->
                    ok
            end,
            case lists:keyfind(U, 1, Users) of
                {U, Y} ->
                    io:format(
                        "[server] ~p (~p) attempted login, but user with same name is already logged in at ~p~n",
                        [U, Pid, Y]
                    ),
                    Pid ! {error, not_unique_username},
                    loop(Users);
                false ->
                    ok
            end,
            io:format("[server] user ~p (~p) logged in~n", [U, Pid]),
            Pid ! {ack},
            monitor(process, Pid),
            loop([{U, Pid} | Users]);
        {logout, U} ->
            io:format("[server] user ~p logged out~n", [U]),
            group_controller ! {disconnect, U},
            loop(lists:delete(U, Users));
        {'DOWN', _, process, Pid, Why} ->
            io:format("[server] user at ~p down: ~p~n", [Pid, Why]),
            U = lists:keyfind(Pid, 2, Users),
            group_controller ! {disconnect, U},
            loop(lists:delete(U, Users));
        X ->
            io:format("[server] WARNING - received: ~p~n", [X]),
            loop(Users)
    end.
