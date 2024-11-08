-module(lab1_8_client).
-export([connect/1, print/1]).

connect(Server) ->
    erlang:set_cookie(my_secret_cookie),
    put(server, Server),
    ok.

print(M) -> rpc:call(get(server), lab1_8_server, print, [M]).

% NOTE: the server must be started before the client can connect to it
% 1. start server
% 2. connect to server
% 3. print message
