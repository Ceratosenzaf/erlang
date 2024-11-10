-module(my_lists).
-compile(export_all).
-compile({no_auto_import, [max/2]}).
-compile({no_auto_import, [min/2]}).

all(_, []) -> true;
all(F, [H | T]) -> F(H) and all(F, T).

any(_, []) -> false;
any(F, [H | T]) -> F(H) or any(F, T).

append([[]]) -> [];
append([H | T]) -> H ++ append(T).

append(A, B) -> A ++ B.

concat([]) -> [];
concat([H | T]) when is_atom(H) -> atom_to_list(H) ++ T;
concat([H | T]) when is_integer(H) -> integer_to_list(H) ++ T;
concat([H | T]) when is_float(H) -> float_to_list(H) ++ T;
concat([H | T]) when is_list(H) -> H ++ T.

delete(E, L) -> L -- [E].

droplast([_]) -> [];
droplast([H | T]) -> [H | droplast(T)].

dropwhile(_, []) ->
    [];
dropwhile(F, [H | T]) ->
    case F(H) of
        true -> dropwhile(F, T);
        false -> [H | T]
    end.

duplicate(0, _) -> [];
duplicate(N, E) -> [E | duplicate(N - 1, E)].

filter(_, []) ->
    [];
filter(F, [H | T]) ->
    case F(H) of
        true -> [H | filter(F, T)];
        false -> filter(F, T)
    end.

filtermap(_, []) ->
    [];
filtermap(F, [H | T]) ->
    case F(H) of
        {true, V} -> [V | filtermap(F, T)];
        false -> filtermap(F, T)
    end.

flatlength([]) -> 0;
flatlength([H | T]) when is_list(H) -> flatlength(H) + flatlength(T);
flatlength([_ | T]) -> flatlength(T) + 1.

flatmap(_, []) -> [];
flatmap(F, [H | T]) -> F(H) ++ flatmap(F, T).

flatten([]) -> [];
flatten([H | T]) when is_list(H) -> flatten(H) ++ flatten(T);
flatten([H | T]) -> [H | flatten(T)].

join(_, []) -> [];
join(_, [H]) -> [H];
join(S, [A, B | T]) -> [A, S | join(S, [B | T])].

foreach(_, []) ->
    ok;
foreach(F, [H | T]) ->
    F(H),
    foreach(F, T).

keydelete(_, _, []) ->
    [];
keydelete(K, N, [H | T]) ->
    case element(N, H) of
        K -> T;
        _ -> [H | keydelete(K, N, T)]
    end.

keyfind(_, _, []) ->
    false;
keyfind(K, N, [H | T]) ->
    case element(N, H) of
        K -> H;
        _ -> keyfind(K, N, T)
    end.

keymember(_, _, []) -> false;
keymember(K, N, [H | T]) -> element(N, H) == K or keymember(K, N, T).

map(_, []) -> [];
map(F, [H | T]) -> [F(H) | map(F, T)].

max([H | T]) -> max(H, T).
max(M, []) -> M;
max(M, [H | T]) when M >= H -> max(M, T);
max(_, [H | T]) -> max(H, T).

member(_, []) -> false;
member(E, [H | T]) -> E == H or member(E, T).

merge([]) -> [];
merge([H | T]) when is_list(H) -> merge(H) ++ merge(T);
merge([H | T]) -> [H | merge(T)].

merge(A, []) -> A;
merge([], B) -> B;
merge([H1 | T1], [H2 | T2]) when H1 =< H2 -> [H1 | merge(T1, [H2 | T2])];
merge([H1 | T1], [H2 | T2]) -> [H2 | merge([H1 | T1], T2)].

min([H | T]) -> min(H, T).
min(M, []) -> M;
min(M, [H | T]) when M =< H -> min(M, T);
min(_, [H | T]) -> min(H, T).

nth(1, [H | _]) -> H;
nth(N, [_ | T]) -> nth(N - 1, T).

nthtail(0, L) -> L;
nthtail(N, [_ | T]) -> nthtail(N - 1, T).

partition(F, L) -> partition(F, [], [], L).
partition(_, A, B, []) ->
    {A, B};
partition(F, A, B, [H | T]) ->
    case F(H) of
        true -> partition(F, A ++ [H], B, T);
        false -> partition(F, A, B ++ [H], T)
    end.

prefix([], _) -> true;
prefix(_, []) -> false;
prefix([H | A], [H | B]) -> prefix(A, B);
prefix(_, _) -> false.

reverse(L) -> reverse([], L).
reverse(Acc, []) -> Acc;
reverse(Acc, [H | T]) -> reverse([H | Acc], T).

search(_, []) ->
    false;
search(F, [H | T]) ->
    case F(H) of
        true -> {value, H};
        false -> search(F, T)
    end.

seq(A, A) -> [A];
seq(A, B) -> [A | seq(A + 1, B)].

seq(A, A, _) -> [A];
seq(A, B, S) when A =< B -> [A | seq(A + S, B, S)];
seq(_, _, _) -> [].

split(N, L) -> split(N, [], L).
split(0, [], A) -> {A, []};
split(1, A, [H | T]) -> {A ++ [H], T};
split(N, A, [H | T]) -> split(N - 1, A ++ [H], T).

splitwith(F, L) -> splitwith(F, [], L).
splitwith(_, A, []) ->
    {A, []};
splitwith(F, A, [H | T]) ->
    case F(H) of
        true -> splitwith(F, A ++ [H], T);
        false -> {A, [H | T]}
    end.

sublist([], _) -> [];
sublist([H | _], 1) -> [H];
sublist([H | T], N) -> [H | sublist(T, N - 1)].

subtract(A, B) -> A -- B.

suffix(A, B) -> nthtail(length(A), B) == A.

sum([]) -> 0;
sum([H | T]) -> H + sum(T).

takewhile(_, []) ->
    [];
takewhile(F, [H | T]) ->
    case F(H) of
        true -> [H | takewhile(F, T)];
        false -> []
    end.

unizp(L) -> unzip([], [], L).
unzip(A, B, []) -> {A, B};
unzip(A, B, [{A1, B1} | T]) -> unzip(A ++ [A1], B ++ [B1], T).

zip([], []) -> [];
zip([A | T1], [B | T2]) -> [{A, B} | zip(T1, T2)].
