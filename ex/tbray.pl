#!/usr/bin/env perl

# -module(tbray).
# -export([start/2]).
#
# find_match("/ongoing/When/" ++ Last) ->
#     case lists:member($., Last) of
#         false -> 1;
#         true -> 0
#     end;
# find_match(_) -> 0.
#
# process_binary(Pid, Bin) ->
#     spawn(fun() ->
#         L = string:tokens(binary_to_list(Bin), "\n"),
#         V = lists:foldl(
#             fun(Line, Total) ->
#                 Total + find_match(lists:nth(7, string:tokens(Line, " "))) end,
#             0, L),
#         Pid ! V
#         end).
#
# split_on_newline(Bin, N, All) when size(Bin) < N ->
#     All ++ [Bin];
# split_on_newline(Bin, N, All) ->
#     {_, <<C:8, _/binary>>} = split_binary(Bin, N),
#     case C of
#         $\n ->
#           {B21, B22} = split_binary(Bin, N+1),
#           split_on_newline(B22, N, All ++ [B21]);
#         _ -> split_on_newline(Bin, N+1, All)
#     end.
# split_on_newline(Bin, N) when N == size(Bin) -> [Bin];
# split_on_newline(Bin, N) -> split_on_newline(Bin, N, []).
#
# start(Num, Input) ->
#     {ok, Data} = file:read_file(Input),
#     Bins = split_on_newline(Data, size(Data) div Num),
#     Me = self(),
#     Pids = [process_binary(Me, B) || B <- Bins],
#     lists:foldl(
#         fun(_, Total) -> receive X -> Total + X end end,
#         0, Pids).

package TBEP;
use MooseX::POE;

sub START {
    while (<>) {
        $self->yield( process_binary => $_ );
    }
}

sub on_process_binary {
    my ($self, $line) = @_;
    
}

no MooseX::POE :

  package MatchFinder;
use MooseX::POE;

sub on_find_match {

}

no MooseX::POE;
