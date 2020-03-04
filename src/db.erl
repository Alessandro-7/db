-module(db).
-export([start/0, stop/0, new/1, create/2, read/2, update/2, delete/2]).
-type db() :: binary().


-type db_record() :: {key(), username(), city()}.
-type key() :: integer().
-type username() :: string().
-type city() :: string().

-type reason() :: term().

% Table structure
-record(dbRec, {key :: key(), username :: username(), city :: city()}).


%% Every CRUD function checking the key for integer type %%
%% Before CUD requests we shoud know is requested key value already in the db %%
%% mnesia functions doesnt check it so we need to do it with read()/2 function %%


start() ->
  mnesia:create_schema([node()]),
  mnesia:start().

stop() ->
  mnesia:stop().

%% Return error if db exists
-spec new(db()) -> ok | {error, reason()}.
new(Table) ->
  case mnesia:create_table(Table, [{disc_copies, [node()]}, {attributes, record_info(fields, dbRec)}]) of
    {atomic, ok} -> ok;
    {aborted, {already_exists, Table}} -> {error, this_db_already_exists}
  end.

%% Return error if the key exists
-spec create(db_record(), db()) -> {ok, db_record()} | {error, reason()}.
create(Record, Table) ->
  Key = element(1, Record),
  if is_integer(Key) ->
      case read(Key, Table) of
        {error, key_doesnt_exist} ->
          F = fun() ->
            mnesia:write({Table, Key, element(2, Record), element(3, Record)})
          end,
          mnesia:activity(transaction, F),
          {ok, Record};
        {ok, _} -> {error, key_exists}
      end;
    true -> {error, maybe_key_isnt_integer}
  end.



%% Return error if the key doesn't exist
-spec read(key(), db()) -> {ok, db_record()} | {error, reason()}.
read(Key, Table) ->
  if is_integer(Key) ->
    F = fun() ->
      case mnesia:read({Table, Key}) of
        [{Table, Key, Username, City}] ->
          {ok, {Key, Username, City}};
        _ ->
          {error, key_doesnt_exist}
      end
    end,
    mnesia:activity(transaction, F);
    true -> {error, maybe_key_isnt_integer}
  end.


%% Return error if the key doesn't exist
-spec update(db_record(), db()) -> {ok, db_record()} | {error, reason()}.
update(Record, Table) ->
  Key = element(1,Record),
  if is_integer(Key) ->
      case read(Key, Table) of
        {ok, _} ->
          F = fun() ->
            mnesia:write({Table, Key, element(2,Record), element(3,Record)})
          end,
          mnesia:activity(transaction, F),
          {ok, Record};
        {error, key_doesnt_exist} -> {error, key_doesnt_exist}
      end;
    true -> {error, maybe_key_isnt_integer}
  end.



%% Return error if the key doesn't exist
-spec delete(key(), db()) -> ok | {error, reason()}.
delete(Key, Table) ->
  if is_integer(Key) ->
    case read(Key, Table) of
      {ok, _} ->
        F = fun() ->
          mnesia:delete({Table, Key})
        end,
        mnesia:activity(transaction, F);
      {error, key_doesnt_exist} -> {error, key_doesnt_exist}
    end;
  true -> {error, maybe_key_isnt_integer}
end.
