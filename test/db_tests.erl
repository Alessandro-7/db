-module(db_tests).

-include_lib("eunit/include/eunit.hrl").

% Tests type of the key
types_test() ->
  db:start(),
  ?assertEqual({error, maybe_key_isnt_integer}, db:read(not_integer, table)),
  ?assertEqual({error, maybe_key_isnt_integer}, db:delete(not_integer, table)),
  ?assertEqual({error, maybe_key_isnt_integer}, db:create({not_integer, "Alessandro", "Spb"}, table)),
  ?assertEqual({error, maybe_key_isnt_integer}, db:update({not_integer, "Alessandro", "Spb"}, table)).

% Tests existence of the key value in the db
 existence_test() ->
  ?assertEqual(ok, db:new(table)),
  ?assertEqual({error, this_db_already_exists}, db:new(table)),
  ?assertMatch({ok, _}, db:create({1, "Alessandro", "Spb"}, table)),
  ?assertEqual({error, key_exists}, db:create({1, "Alessandro", "Spb"}, table)),
  ?assertMatch({ok, _}, db:read(1, table)),
  ?assertMatch({ok, _}, db:update({1, "Alessandro", "Moscow"}, table)),
  ?assertEqual(ok, db:delete(1, table)),
  ?assertEqual({error, key_doesnt_exist}, db:update({1, "Alessandro", "Spb"}, table)),
  ?assertEqual({error, key_doesnt_exist}, db:read(1, table)).


% Tests exceptions not asked to handle
% As an example here we try to request nonexistent db
errors_test() ->
  ?assertExit({aborted, {no_exists, _}}, db:create({1, "Alessandro", "Spb"}, other_table)).
