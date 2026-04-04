(******************************************************************************
 * LuaJIT — Auxiliary library (lauxlib.h)
 ******************************************************************************)

{$IFDEF FPC}{$MODE OBJFPC}{$H+}{$ENDIF}

unit lauxlib51;

interface

uses
  luajit51;

const
  LUAJIT_AUX_LIB = luajit51.LUAJIT_LIB;

  LUA_ERRFILE = LUA_ERRERR + 1;

  LUA_NOREF  = -2;
  LUA_REFNIL = -1;

  (* Must match LuaJIT luaconf.h LUAL_BUFFERSIZE for your platform (often 8192). *)
  LUAL_BUFFERSIZE = 8192;

type
  luaL_Reg = record
    name: PAnsiChar;
    func: lua_CFunction;
  end;
  PluaL_Reg = ^luaL_Reg;

  luaL_Buffer = record
    p: PAnsiChar;
    lvl: Integer;
    LuaState: Plua_State;  (* C field name L; renamed — avoids clash with param L in this unit *)
    buffer: array[0..LUAL_BUFFERSIZE - 1] of AnsiChar;
  end;
  PluaL_Buffer = ^luaL_Buffer;

procedure luaL_openlib(L: Plua_State; const libname: PAnsiChar; const lr: PluaL_Reg; nup: Integer); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_register(L: Plua_State; const libname: PAnsiChar; const lr: PluaL_Reg); cdecl; external LUAJIT_AUX_LIB;

function luaL_getmetafield(L: Plua_State; obj: Integer; const e: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_callmeta(L: Plua_State; obj: Integer; const e: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_typerror(L: Plua_State; narg: Integer; const tname: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_argerror(L: Plua_State; numarg: Integer; const extramsg: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;

function luaL_checklstring(L: Plua_State; numArg: Integer; len: Psize_t): PAnsiChar; cdecl; external LUAJIT_AUX_LIB;
function luaL_optlstring(L: Plua_State; numArg: Integer; const def: PAnsiChar; len: Psize_t): PAnsiChar; cdecl; external LUAJIT_AUX_LIB;
function luaL_checknumber(L: Plua_State; numArg: Integer): lua_Number; cdecl; external LUAJIT_AUX_LIB;
function luaL_optnumber(L: Plua_State; nArg: Integer; def: lua_Number): lua_Number; cdecl; external LUAJIT_AUX_LIB;
function luaL_checkinteger(L: Plua_State; numArg: Integer): lua_Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_optinteger(L: Plua_State; nArg: Integer; def: lua_Integer): lua_Integer; cdecl; external LUAJIT_AUX_LIB;

procedure luaL_checkstack(L: Plua_State; sz: Integer; const msg: PAnsiChar); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_checktype(L: Plua_State; narg, t: Integer); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_checkany(L: Plua_State; narg: Integer); cdecl; external LUAJIT_AUX_LIB;

function luaL_newmetatable(L: Plua_State; const tname: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_checkudata(L: Plua_State; ud: Integer; const tname: PAnsiChar): Pointer; cdecl; external LUAJIT_AUX_LIB;

procedure luaL_where(L: Plua_State; lvl: Integer); cdecl; external LUAJIT_AUX_LIB;
function luaL_error(L: Plua_State; const fmt: PAnsiChar): Integer; cdecl; varargs; external LUAJIT_AUX_LIB;

function luaL_checkoption(L: Plua_State; narg: Integer; const def: PAnsiChar; const lst: PPAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;

function luaL_ref(L: Plua_State; t: Integer): Integer; cdecl; external LUAJIT_AUX_LIB;
procedure luaL_unref(L: Plua_State; t, ref: Integer); cdecl; external LUAJIT_AUX_LIB;

function luaL_loadfile(L: Plua_State; const filename: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_loadbuffer(L: Plua_State; const buff: PAnsiChar; sz: size_t; const name: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_loadstring(L: Plua_State; const s: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;

function luaL_newstate: Plua_State; cdecl; external LUAJIT_AUX_LIB;

function luaL_gsub(L: Plua_State; const s, p, r: PAnsiChar): PAnsiChar; cdecl; external LUAJIT_AUX_LIB;
function luaL_findtable(L: Plua_State; idx: Integer; const fname: PAnsiChar; szhint: Integer): PAnsiChar; cdecl; external LUAJIT_AUX_LIB;

function luaL_fileresult(L: Plua_State; stat: Integer; const fname: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_execresult(L: Plua_State; stat: Integer): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_loadfilex(L: Plua_State; const filename, mode: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
function luaL_loadbufferx(L: Plua_State; const buff: PAnsiChar; sz: size_t; const name, mode: PAnsiChar): Integer; cdecl; external LUAJIT_AUX_LIB;
procedure luaL_traceback(L: Plua_State; L1: Plua_State; const msg: PAnsiChar; level: Integer); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_setfuncs(L: Plua_State; const reg: PluaL_Reg; nup: Integer); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_pushmodule(L: Plua_State; const modname: PAnsiChar; sizehint: Integer); cdecl; external LUAJIT_AUX_LIB;
function luaL_testudata(L: Plua_State; ud: Integer; const tname: PAnsiChar): Pointer; cdecl; external LUAJIT_AUX_LIB;
procedure luaL_setmetatable(L: Plua_State; const tname: PAnsiChar); cdecl; external LUAJIT_AUX_LIB;

procedure luaL_buffinit(L: Plua_State; B: PluaL_Buffer); cdecl; external LUAJIT_AUX_LIB;
function luaL_prepbuffer(B: PluaL_Buffer): PAnsiChar; cdecl; external LUAJIT_AUX_LIB;
procedure luaL_addlstring(B: PluaL_Buffer; const s: PAnsiChar; ls: size_t); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_addstring(B: PluaL_Buffer; const s: PAnsiChar); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_addvalue(B: PluaL_Buffer); cdecl; external LUAJIT_AUX_LIB;
procedure luaL_pushresult(B: PluaL_Buffer); cdecl; external LUAJIT_AUX_LIB;

procedure luaL_argcheck(L: Plua_State; cond: Boolean; arg: Integer; extramsg: PAnsiChar); inline;
function luaL_checkstring(L: Plua_State; n: Integer): PAnsiChar; inline;
function luaL_optstring(L: Plua_State; n: Integer; d: PAnsiChar): PAnsiChar; inline;
function luaL_typename(L: Plua_State; i: Integer): PAnsiChar; inline;

implementation

procedure luaL_argcheck(L: Plua_State; cond: Boolean; arg: Integer; extramsg: PAnsiChar);
begin
  if not cond then
    luaL_argerror(L, arg, extramsg);
end;

function luaL_checkstring(L: Plua_State; n: Integer): PAnsiChar;
begin
  Result := luaL_checklstring(L, n, nil);
end;

function luaL_optstring(L: Plua_State; n: Integer; d: PAnsiChar): PAnsiChar;
begin
  Result := luaL_optlstring(L, n, d, nil);
end;

function luaL_typename(L: Plua_State; i: Integer): PAnsiChar;
begin
  Result := lua_typename(L, lua_type(L, i));
end;

end.
