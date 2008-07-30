Definitions.

ST = [^"]
L = [A-Za-z]
WS  = ([\000-\s]|%.*)
D = [0-9]
H = [0-9a-fA-F]

Rules.

{   : {token, {'{', TokenLine}}.
}   : {token, {'}', TokenLine}}.

\[   : {token, {'[', TokenLine}}.
\]   : {token, {']', TokenLine}}.

\-?{D}+\.{D}+((E|e)(\+|\-)?{D}+)? : {token,{float,TokenLine,list_to_float(TokenChars)}}.
\-?{D}+(E|e)(\+|\-)?{D}+ : {token,{float,TokenLine,whole_float(TokenChars)}}.
\-?{D}+		:	{token,{integer,TokenLine,list_to_integer(TokenChars)}}.

% "[^"\\]*(\\[^u][^"\\]*)*"  : {token,{string,TokenLine,strip(unicode_string(TokenChars),TokenLen)}}.
"[^"\\]*(\\.[^"\\]*)*"  : {token,{string,TokenLine,parse_string(strip(TokenChars,TokenLen))}}.


% \\u{H}{H}{H}{H} : {token, {unicode, TokenLine,TokenChars}}.

true : {token,{'true', TokenLine}}.
false : {token,{'false', TokenLine}}.
null : {token,{'null', TokenLine}}.

: : {token, {':', TokenLine}}.
, : {token, {',', TokenLine}}.

{WS}+       :   skip_token.

Erlang code.
% "

-define(LOG(Name, Value), 
        io:format("{~p:~p}: ~p -> ~s~n", [?MODULE, ?LINE, Name, Value])).
-define(PLOG(Name, Value), 
        io:format("{~p:~p}: ~p -> ~p~n", [?MODULE, ?LINE, Name, Value])).

strip(TokenChars,TokenLen) -> lists:sublist(TokenChars, 2, TokenLen - 2).

whole_float(TokenChars) ->
  {ok, NowFloat, 1 } = regexp:sub(TokenChars,"e",".0e"),
  list_to_float(NowFloat).

unescape([$\\,$\"|Cs]) -> [$\"|unescape(Cs)];
unescape([$\\,$\\|Cs]) -> [$\\|unescape(Cs)];
unescape([$\\,$/|Cs]) -> [$/|unescape(Cs)];
unescape([$\\,$b|Cs]) -> [$\b|unescape(Cs)];
unescape([$\\,$f|Cs]) -> [$\f|unescape(Cs)];
unescape([$\\,$n|Cs]) -> [$\n|unescape(Cs)];
unescape([$\\,$r|Cs]) -> [$\r|unescape(Cs)];
unescape([$\\,$t|Cs]) -> [$\t|unescape(Cs)];
unescape([$\\,$u,C0,C1,C2,C3|Cs]) ->
    C = dehex(C3) bor
	(dehex(C2) bsl 4) bor
	(dehex(C1) bsl 8) bor
	(dehex(C0) bsl 12),
    [C|unescape(Cs)];
unescape([C|Cs]) -> [C|unescape(Cs)];
unescape([]) -> [].

dehex(C) when C >= $0, C =< $9 -> C - $0;
dehex(C) when C >= $a, C =< $f -> C - $a + 10;
dehex(C) when C >= $A, C =< $F -> C - $A + 10.

parse_string(StringChars) -> 
    unescape(StringChars).
