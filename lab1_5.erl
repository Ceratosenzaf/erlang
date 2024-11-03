-module(lab1_5).
-export([parse/1, evaluate/1]).

% parse
% exp = v | (exp op exp)
% v -> {num, v}
% op -> plus | minus | multiply | divide
% (exp op exp) -> {exp1, op, exp2}

operator($+) -> plus; 
operator($-) -> minus; 
operator($*) -> multiply; 
operator($/) -> divide.

parse(L) -> parse(L, []).

parse([], [E]) -> E;
parse([$)|T], [E2, Op, E1|Es]) -> parse(T, [{E1, Op, E2}|Es]);
parse([$(|T], Es) -> parse(T, Es);
parse([V|T], Es) when V >= $0 andalso V =< $9 -> parse(T, [{num, V - $0}|Es]);
parse([V|T], [E|Es]) -> parse(T, [operator(V), E|Es]).

% evaluate
% evaluate({num, v}) -> v
% evaluate({exp1, op, exp2}) -> exec(op, evaluate(exp1), evaluate(exp2))

exec(plus, V1, V2) -> V1 + V2;
exec(minus, V1, V2) -> V1 - V2;
exec(multiply, V1, V2) -> V1 * V2;
exec(divide, V1, V2) -> V1 / V2.

evaluate({num, V}) -> V;
evaluate({E1, Op, E2}) -> exec(Op, evaluate(E1), evaluate(E2)).



