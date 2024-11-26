-module(group_controller).
-export([start/0]).

start() ->
    erlang:set_cookie(node(), my_cookie),
    loop([]).

loop(Groups) ->
    receive
        {connect, G, {U, P}} ->
            io:format("[gc] user ~p requested to connect to group ~p~n", [{U, P}, G]),
            P ! {connected, {U, P}},
            case lists:keyfind(G, 1, Groups) of
                false ->
                    loop([{G, [{U, P}]} | Groups]);
                {G, Users} ->
                    lists:foreach(fun({_, Pid}) -> Pid ! {connected, {U, P}} end, Users),
                    loop([{G, [{U, P} | Users]} | lists:delete({G, Users}, Groups)])
            end;
        {disconnect, U} ->
            io:format("[gc] user ~p requested to disconnect from current group~n", [U]),
            case user_group(U, Groups) of
                not_found ->
                    loop(Groups);
                {G, Users} ->
                    lists:foreach(fun({_, Pid}) -> Pid ! {disconnected, U} end, Users),
                    loop([{G, lists:delete(U, Users)} | lists:delete({G, Users}, Groups)])
            end;
        {msg, M, U} ->
            io:format("[gc] user ~p sending message: ~p~n", [U, M]),
            case user_group(U, Groups) of
                not_found -> ok;
                {_, Users} -> lists:foreach(fun({_, Pid}) -> Pid ! {msg, M, from, U} end, Users)
            end,
            loop(Groups);
        {list_groups, {U, Pid}} ->
            io:format("[gc] user ~p requested groups list~n", [{U, Pid}]),
            Pid ! lists:map(fun({GN, _}) -> GN end, Groups),
            loop(Groups);
        {list_users, {U, Pid}} ->
            io:format("[gc] user ~p requested users list~n", [{U, Pid}]),
            case user_group({U, Pid}, Groups) of
                not_found -> Pid ! not_connected_to_group;
                {_, GU} -> Pid ! lists:map(fun({UN, _}) -> UN end, GU)
            end,
            loop(Groups);
        X ->
            io:format("[gc] WARNING - received: ~p~n", [X]),
            loop(Groups)
    end.

user_group(_, []) ->
    not_found;
user_group(U, [{GN, GU} | T]) ->
    case user_in_group(U, GU) of
        true -> {GN, GU};
        false -> user_group(U, T)
    end.

user_in_group(_, []) -> false;
user_in_group(U, [U | _]) -> true;
user_in_group(U, [_ | T]) -> user_in_group(U, T).
