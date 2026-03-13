(******************************************************************************
 * Пример: вызов коллбеков Lua из Pascal и передача функций в обе стороны.
 *
 * 1) Pascal → Lua: регистрируем C-функции, Lua их вызывает (как в mymodule).
 * 2) Lua → Pascal: Lua передаёт функцию на стек; Pascal сохраняет и потом
 *    вызывает (callback).
 * 3) Pascal вызывает Lua-функцию с аргументами и читает результаты.
 *
 * Сборка: fpc -Fu"../src" -Fi"../src" callbacks.lpr
 * Запуск: callbacks callbacks_demo.lua
 ******************************************************************************)

program callbacks;

{$MODE OBJFPC}{$H+}

uses
  SysUtils,
  lua54,
  lauxlib54,
  lualib54;

var
  L: Plua_State;
  stored_callback_ref: Integer = LUA_NOREF;  // ссылка на сохранённую Lua-функцию в реестре

(**
 * call_lua_func(func, arg1?, arg2?, ...)
 * Вызвать из Pascal переданную Lua-функцию с аргументами.
 * Стек: 1 = функция, 2..n = аргументы. Возвращает результаты функции.
 *)
function call_lua_func(L: Plua_State): Integer; cdecl;
var
  nargs: Integer;
begin
  nargs := lua_gettop(L) - 1;  // минус сама функция
  if nargs < 0 then
    nargs := 0;
  if lua_type(L, 1) <> LUA_TFUNCTION then
  begin
    lua_pushstring(L, 'call_lua_func: first argument must be a function');
    lua_error(L);
    Result := 0;
    exit;
  end;
  lua_rotate(L, 1, nargs);  // [arg1..argn][func] → функция на вершине
  if lua_pcall(L, nargs, LUA_MULTRET, 0) <> LUA_OK then
  begin
    lua_error(L);  // пробрасываем ошибку Lua
    Result := 0;
    exit;
  end;
  Result := lua_gettop(L);  // число возвращённых значений
end;

(**
 * store_callback(func)
 * Сохранить Lua-функцию в реестре; потом её можно вызвать из Pascal через invoke_stored.
 *)
function store_callback(L: Plua_State): Integer; cdecl;
begin
  luaL_checktype(L, 1, LUA_TFUNCTION);
  if stored_callback_ref <> LUA_NOREF then
    luaL_unref(L, LUA_REGISTRYINDEX, stored_callback_ref);
  lua_pushvalue(L, 1);
  stored_callback_ref := luaL_ref(L, LUA_REGISTRYINDEX);
  lua_pushboolean(L, True);
  Result := 1;
end;

(**
 * invoke_stored()
 * Вызвать сохранённую ранее через store_callback Lua-функцию (без аргументов).
 * Возвращает то, что вернула функция.
 *)
function invoke_stored(L: Plua_State): Integer; cdecl;
begin
  if stored_callback_ref = LUA_NOREF then
  begin
    lua_pushstring(L, 'invoke_stored: no callback stored (call store_callback first)');
    lua_error(L);
    Result := 0;
    exit;
  end;
  lua_rawgeti(L, LUA_REGISTRYINDEX, stored_callback_ref);
  if lua_pcall(L, 0, LUA_MULTRET, 0) <> LUA_OK then
  begin
    lua_error(L);
    Result := 0;
    exit;
  end;
  Result := lua_gettop(L);
end;

(**
 * pascal_side_calc(a, b)
 * Пример: функция на Pascal, которую вызывает Lua; она сама вызывает переданную Lua-функцию.
 * Здесь для демо просто возвращаем a + b и вызываем сохранённый коллбек, если он есть.
 *)
function pascal_side_calc(L: Plua_State): Integer; cdecl;
var
  a, b: Integer;
begin
  a := luaL_checkinteger(L, 1);
  b := luaL_checkinteger(L, 2);
  lua_pushinteger(L, a + b);
  if stored_callback_ref <> LUA_NOREF then
  begin
    lua_pushvalue(L, -1);  // копия результата (a+b) для аргумента коллбека
    lua_rawgeti(L, LUA_REGISTRYINDEX, stored_callback_ref);
    lua_rotate(L, -2, 1);  // [result][copy][callback] → [result][callback][copy]
    if lua_pcall(L, 1, 0, 0) <> LUA_OK then
      lua_error(L);
  end;
  Result := 1;  // возвращаем a+b
end;

procedure RegisterCallbacks(L: Plua_State);
const
  reg: array[0..4] of luaL_Reg = (
    (name: 'call_lua_func';  func: @call_lua_func),
    (name: 'store_callback'; func: @store_callback),
    (name: 'invoke_stored';  func: @invoke_stored),
    (name: 'pascal_side_calc'; func: @pascal_side_calc),
    (name: nil;              func: nil)
  );
begin
  lua_createtable(L, 0, 4);
  luaL_setfuncs(L, @reg[0], 0);
  lua_setglobal(L, 'pascal');
end;

var
  script: string;

begin
  L := luaL_newstate;
  if L = nil then
  begin
    Writeln(ErrOutput, 'Failed to create Lua state');
    Halt(1);
  end;
  try
    luaL_openlibs(L);
    RegisterCallbacks(L);

    if ParamCount >= 1 then
      script := ParamStr(1)
    else
      script := 'callbacks_demo.lua';

    if luaL_loadfile(L, PAnsiChar(AnsiString(script))) <> LUA_OK then
    begin
      Writeln(ErrOutput, 'load: ', lua_tostring(L, -1));
      lua_pop(L, 1);
      Halt(1);
    end;
    if lua_pcall(L, 0, 0, 0) <> LUA_OK then
    begin
      Writeln(ErrOutput, 'run: ', lua_tostring(L, -1));
      lua_pop(L, 1);
      Halt(1);
    end;
  finally
    if stored_callback_ref <> LUA_NOREF then
      luaL_unref(L, LUA_REGISTRYINDEX, stored_callback_ref);
    lua_close(L);
  end;
end.
