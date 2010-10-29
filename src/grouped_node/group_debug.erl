%  @copyright 2007-2010 Konrad-Zuse-Zentrum fuer Informationstechnik Berlin

%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.

%% @author Thorsten Schuett <schuett@zib.de>
%% @version $Id$
-module(group_debug).
-author('schuett@zib.de').
-vsn('$Id$').

-include("scalaris.hrl").

-export([dbg/0, dbg_version/0, dbg3/0, dbg_mode/0, dbg_db/0, dbg_db_without_pid/0]).

-spec dbg() -> any().
dbg() ->
    gb_trees:to_list(lists:foldl(fun (Node, Stats) ->
                        State = gen_component:get_state(Node, 100),
                        View = group_state:get_view(State),
                        case group_state:get_mode(State) of
                            joined ->
                                inc(Stats, group_view:get_group_id(View));
                            _ ->
                                Stats
                        end
                end, gb_trees:empty(), pid_groups:find_all(group_node))).

inc(Stats, Label) ->
    case gb_trees:lookup(Label, Stats) of
        {value, Counter} ->
            gb_trees:update(Label, Counter + 1, Stats);
        none ->
            gb_trees:insert(Label, 1, Stats)
    end.

-spec dbg_version() -> any().
dbg_version() ->
    lists:map(fun (Node) ->
                      State = gen_component:get_state(Node, 1000),
                      io:format("~p~n", [State]),
                      View = group_state:get_view(State),
                      case group_state:get_mode(State) of
                          joined ->
                              {Node, group_view:get_current_paxos_id(View)};
                          _ ->
                              {Node, '_'}
                      end
              end, pid_groups:find_all(group_node)).

-spec dbg3() -> any().
dbg3() ->
    lists:map(fun (Node) ->
                      State = gen_component:get_state(Node, 1000),
                      View = group_state:get_view(State),
                      case group_state:get_mode(State) of
                          joined ->
                              {Node, length(group_view:get_postponed_decisions(View))};
                          _ ->
                              {Node, '_'}
                      end
              end, pid_groups:find_all(group_node)).

-spec dbg_mode() -> any().
dbg_mode() ->
    lists:map(fun (Node) ->
                      State = gen_component:get_state(Node, 1000),
                      {Node, group_state:get_mode(State)}
              end, pid_groups:find_all(group_node)).

-spec dbg_db() -> any().
dbg_db() ->
    lists:map(fun (Node) ->
                      State = gen_component:get_state(Node, 1000),
                      DB = group_state:get_db(State),
                      Size = group_db:get_size(DB),
                      {Node, element(1, DB), Size}
              end, pid_groups:find_all(group_node)).

-spec dbg_db_without_pid() -> any().
dbg_db_without_pid() ->
    lists:map(fun (Node) ->
                      State = gen_component:get_state(Node, 1000),
                      DB = group_state:get_db(State),
                      Size = group_db:get_size(DB),
                      {element(1, DB), Size}
              end, pid_groups:find_all(group_node)).
