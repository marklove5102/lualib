(******************************************************************************
 * Пример хоста: вызов LuaJIT из Pascal (C API Lua 5.1 / LuaJIT).
 *
 * Windows: lua51.dll или luajit.dll рядом с exe или в PATH.
 * Linux:   libluajit-5.1.so.2 (или .so) в LD_LIBRARY_PATH / системном пути.
 *
 * Сборка из корня: ./build_run_luajit.sh
 * Или: fpc -Tlinux -Px86_64 -Fu"../src" -Fi"../src" run_luajit.lpr (из example)
 *
 * Запуск: run_luajit [файл.lua]  или без аргументов — встроенная строка (печать + jit.status)
 ******************************************************************************)

program run_luajit;

{$MODE OBJFPC}{$H+}

uses
  SysUtils,
  luajit51,
  lauxlib51,
  lualib51;

var
  L: Plua_State;
  script: string;

begin
  L := luaL_newstate;
  if L = nil then
  begin
    Writeln(ErrOutput, 'Failed to create LuaJIT state');
    Halt(1);
  end;
  try
    luaL_openlibs(L);

    if ParamCount >= 1 then
    begin
      script := ParamStr(1);
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
    end
    else
    begin
      if luaL_loadstring(L, PAnsiChar(AnsiString(
        'print("Hello from LuaJIT via Pascal!"); ' +
        'if jit then print(jit.version) else print("(no jit table)") end'))) <> LUA_OK then
      begin
        Writeln(ErrOutput, lua_tostring(L, -1));
        lua_pop(L, 1);
        Halt(1);
      end;
      if lua_pcall(L, 0, 0, 0) <> LUA_OK then
      begin
        Writeln(ErrOutput, lua_tostring(L, -1));
        lua_pop(L, 1);
        Halt(1);
      end;
    end;
  finally
    lua_close(L);
  end;
end.
