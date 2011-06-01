%%%-------------------------------------------------------------------
%%% File: mpstr.erl
%%% Author: Abel Perez
%%%
%%% @doc
%%%  Functions related to processing strings.
%%% @end
%%%-------------------------------------------------------------------
-module(mpstr).

%%--------------------------------------------------------------------
%% External exports
%%--------------------------------------------------------------------
-export([
	remove/2,
	remove_all/2,
	is_phone/1,
	byte_format/1,
	byte_format/2,
	makeSeoName/1,
	dedupe/1,
	word_frequency/1,
	words/1
	]).

words(S) ->
    remove_all(S, ["<", ">"]).
    
%%--------------------------------------------------------------------
%% @doc
%% 
%% @spec word_frequency(List) -> Dict
%% @end
%%--------------------------------------------------------------------
word_frequency(L) -> word_frequency(L, dict:new()).

%%--------------------------------------------------------------------
%% @doc
%% 
%% @spec word_frequency(List, Dict) -> Dict
%% @end
%%--------------------------------------------------------------------
word_frequency([], D) -> D;
word_frequency([H|T], D) ->
    case dict:is_key(H, D) of
        true ->
            word_frequency(T, dict:update(H, fun(Old) -> Old + 1 end, D));
        false ->
            word_frequency(T, dict:store(H, 1, D))
    end.
 
%%--------------------------------------------------------------------
%% @doc
%%  Removes all the duplicate elements from the specified List and 
%%  returns a new List with no duplicates.
%% @spec dedupe(List) -> NewList
%% @end
%%--------------------------------------------------------------------
dedupe(L) -> dedupe(L, []).

%%--------------------------------------------------------------------
%% @doc
%%  
%% @spec dedupe(List, NewList) -> NewList
%% @end
%%--------------------------------------------------------------------
dedupe([], R) -> R;
dedupe([H|T], R) ->
    case lists:member(H, R) of
        true ->
            dedupe(T, R);
        false ->
            dedupe(T, lists:append([H], R))
    end.
    
%%--------------------------------------------------------------------
%% @doc
%%  Removes all occurrence of any of the specified tokens within the 
%%  given string.  For example, given the example string "H-e+llo World"
%%  this function will return the value "Hello World".
%% @spec remove_all(String, TokenList) -> NewString
%% @end
%%--------------------------------------------------------------------
remove_all(S, L) -> do_remove_all(S, L).

%%--------------------------------------------------------------------
%% @doc
%%  Removes any occurrence of the specified token within the given 
%%  string.  For example, given the example string "Hell-o Worl-d"
%%  this function will return the value "Hello World".
%% @spec remove(String, Token) -> NewString
%% @end
%%--------------------------------------------------------------------
remove(S, Token) -> do_remove(S, Token).

%%--------------------------------------------------------------------
%% @doc
%%
%%
%% @spec makeSeo(Title) -> NewSeoString
%% @end
%%--------------------------------------------------------------------
makeSeoName(Title) ->
    re:replace(string:strip(string:to_lower(Title), both), 
            "[^a-z0-9_-]", "", [{return,list}]).
   	
%%--------------------------------------------------------------------
%% @doc
%%  Verifies that the specified phone number is an actual valid phone
%%  number.  This function does not check the prefix and exchange part
%%  of the phone number against a national phone database, instead it
%%  simply verifies that the given phone is properly formatted and is
%%  the correct length.  
%%
%%  The given phone number can be in any valid phone number
%%  format.  For example, the following combinations are considered
%%  valid phone numbers:
%%  (213) 221 2222
%%  (212) 221-2222
%%  213-221-2222
%%
%%  In other words, the characters "(", ")", "-", " " are all valid
%%  characters that can be contained in the specified phone number.
%%  This function effectively drops any of the acceptable phone 
%%  number format characters and verifies the length of the phone is
%%  10 digits long.
%%
%% @spec is_phone(Phone) -> true | false
%% @end
%%--------------------------------------------------------------------
is_phone(Phone) ->
    T = remove_all(Phone, ["(", ")", "-", " "]),  
    case is_integer((catch list_to_integer(T))) of
        false -> false;
        true  -> case string:len(T) of
            10 -> true;
            _  -> false
        end
    end.

%%--------------------------------------------------------------------
%% @doc
%%  Returns the byte format of the specified number and adds the 
%%  appropriate suffix i.e., TB, GB, MB, etc.
%%
%% @spec byte_format(N) -> ByteFormatString
%% @end
%%--------------------------------------------------------------------
byte_format(N) when is_integer(N) ->
    case N of
        N when N >= 1000000000000 -> 
            byte_format(round(N / 1099511627776), " TB");
        N when N >= 1000000000 ->
            byte_format(round(N / 1073741824), " GB");
        N when N >= 1000000 ->
            byte_format(round(N / 1048576), " MB");
        N when N >= 1000 ->
            byte_format(round(N / 1024), " KB");
        N when N <  1000 -> 
            byte_format(N, " bytes")
    end.

%%--------------------------------------------------------------------
%% @doc
%%  Returns the specified number N and byte format in a human readable
%%  format appropriate for display.  For example, given the number: 
%%  1024 and the type: Bytes, the formatted value will be: "1024 Bytes".
%%
%% @spec byte_format(N, Type) -> ByteFormatString
%% @end
%%--------------------------------------------------------------------
byte_format(N, Type) ->
    string:concat(integer_to_list(N), Type).

%%====================================================================
%% Internal functions
%%====================================================================
do_remove_all(S, []) -> S;
do_remove_all(S, [H|T]) -> do_remove_all(do_remove(S, H), T).

do_remove(S, Token) ->
    Position = string:str(S, Token),
    case Position of
        0 ->
            S;
        _ ->
            L = string:left(S, Position - 1),
            R = string:right(S, string:len(S) - string:len(Token) - Position + 1),
            do_remove(string:concat(string:concat(L, ""), R), Token)
    end.

