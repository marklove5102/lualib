(******************************************************************************
 * LuaJIT 2.1 — Pascal bindings to C API (lua.h)
 * Dynamic link: libluajit-5.1.so* (Unix) / lua51.dll or luajit.dll (Windows).
 * Do not mix with lua54 in the same module for one lua_State*.
 ******************************************************************************)

{$IFDEF FPC}{$MODE OBJFPC}{$H+}{$ENDIF}

unit luajit51;

interface

const
  {$IFDEF UNIX}
  LUAJIT_LIB = 'libluajit-5.1.so.2';
  {$ELSE}
  LUAJIT_LIB = 'lua51.dll';
  {$ENDIF}

type
  size_t = PtrUInt;
  Psize_t = ^size_t;

const
  LUA_VERSION_MAJOR   = '5';
  LUA_VERSION_MINOR   = '1';
  LUA_VERSION_NUM     = 501;
  LUA_VERSION_RELEASE = 'Lua 5.1.4';
  LUA_COPYRIGHT       = 'Copyright (C) 1994-2008 Lua.org, PUC-Rio';
  LUA_AUTHORS         = 'R. Ierusalimschy, L. H. de Figueiredo & W. Celes';

  LUA_SIGNATURE       = #27 + 'Lua';

  LUA_MULTRET         = -1;

  LUA_REGISTRYINDEX   = -10000;
  LUA_ENVIRONINDEX    = -10001;
  LUA_GLOBALSINDEX    = -10002;

  LUA_OK              = 0;
  LUA_YIELD_          = 1;  (* thread status; not LUA_YIELD — clashes with lua_yield() *)
  LUA_ERRRUN          = 2;
  LUA_ERRSYNTAX       = 3;
  LUA_ERRMEM          = 4;
  LUA_ERRERR          = 5;

  LUA_TNONE           = -1;
  LUA_TNIL            = 0;
  LUA_TBOOLEAN        = 1;
  LUA_TLIGHTUSERDATA  = 2;
  LUA_TNUMBER         = 3;
  LUA_TSTRING         = 4;
  LUA_TTABLE          = 5;
  LUA_TFUNCTION       = 6;
  LUA_TUSERDATA       = 7;
  LUA_TTHREAD         = 8;

  LUA_MINSTACK        = 20;

  LUA_GCSTOP          = 0;
  LUA_GCRESTART       = 1;
  LUA_GCCOLLECT       = 2;
  LUA_GCCOUNT         = 3;
  LUA_GCCOUNTB        = 4;
  LUA_GCSTEP          = 5;
  LUA_GCSETPAUSE      = 6;
  LUA_GCSETSTEPMUL    = 7;
  LUA_GCISRUNNING     = 9;

  LUA_HOOKCALL        = 0;
  LUA_HOOKRET         = 1;
  LUA_HOOKLINE        = 2;
  LUA_HOOKCOUNT       = 3;
  LUA_HOOKTAILRET     = 4;

  LUA_MASKCALL        = 1 shl LUA_HOOKCALL;
  LUA_MASKRET         = 1 shl LUA_HOOKRET;
  LUA_MASKLINE        = 1 shl LUA_HOOKLINE;
  LUA_MASKCOUNT       = 1 shl LUA_HOOKCOUNT;

  LUA_IDSIZE          = 60;

type
  Plua_State = Pointer;

  lua_Number = Double;
  Plua_Number = ^lua_Number;
  lua_Integer = PtrInt;

  lua_CFunction = function(L: Plua_State): Integer; cdecl;

  lua_Reader = function(L: Plua_State; ud: Pointer; sz: Psize_t): PAnsiChar; cdecl;
  lua_Writer = function(L: Plua_State; const p: Pointer; sz: size_t; ud: Pointer): Integer; cdecl;
  lua_Alloc = function(ud, ptr: Pointer; osize, nsize: size_t): Pointer; cdecl;

  lua_Debug = record
    event: Integer;
    name: PAnsiChar;
    namewhat: PAnsiChar;
    what: PAnsiChar;
    source: PAnsiChar;
    currentline: Integer;
    nups: Integer;
    linedefined: Integer;
    lastlinedefined: Integer;
    short_src: array[0..LUA_IDSIZE - 1] of AnsiChar;
    i_ci: Integer;
  end;
  Plua_Debug = ^lua_Debug;

  lua_Hook = procedure(L: Plua_State; ar: Plua_Debug); cdecl;

function lua_upvalueindex(i: Integer): Integer; inline;

(* state *)
function lua_newstate(f: lua_Alloc; ud: Pointer): Plua_State; cdecl; external LUAJIT_LIB;
procedure lua_close(L: Plua_State); cdecl; external LUAJIT_LIB;
function lua_newthread(L: Plua_State): Plua_State; cdecl; external LUAJIT_LIB;
function lua_atpanic(L: Plua_State; panicf: lua_CFunction): lua_CFunction; cdecl; external LUAJIT_LIB;

(* stack *)
function lua_gettop(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;
procedure lua_settop(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_pushvalue(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_remove(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_insert(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_replace(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
function lua_checkstack(L: Plua_State; sz: Integer): Integer; cdecl; external LUAJIT_LIB;
procedure lua_xmove(from_, to_: Plua_State; n: Integer); cdecl; external LUAJIT_LIB;

(* access *)
function lua_isnumber(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_isstring(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_iscfunction(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_isuserdata(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_type(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_typename(L: Plua_State; tp: Integer): PAnsiChar; cdecl; external LUAJIT_LIB;

function lua_equal(L: Plua_State; idx1, idx2: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_rawequal(L: Plua_State; idx1, idx2: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_lessthan(L: Plua_State; idx1, idx2: Integer): Integer; cdecl; external LUAJIT_LIB;

function lua_tonumber(L: Plua_State; idx: Integer): lua_Number; cdecl; external LUAJIT_LIB;
function lua_tointeger(L: Plua_State; idx: Integer): lua_Integer; cdecl; external LUAJIT_LIB;
function lua_toboolean(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_tolstring(L: Plua_State; idx: Integer; len: Psize_t): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_objlen(L: Plua_State; idx: Integer): size_t; cdecl; external LUAJIT_LIB;
function lua_tocfunction(L: Plua_State; idx: Integer): lua_CFunction; cdecl; external LUAJIT_LIB;
function lua_touserdata(L: Plua_State; idx: Integer): Pointer; cdecl; external LUAJIT_LIB;
function lua_tothread(L: Plua_State; idx: Integer): Plua_State; cdecl; external LUAJIT_LIB;
function lua_topointer(L: Plua_State; idx: Integer): Pointer; cdecl; external LUAJIT_LIB;

(* push *)
procedure lua_pushnil(L: Plua_State); cdecl; external LUAJIT_LIB;
procedure lua_pushnumber(L: Plua_State; n: lua_Number); cdecl; external LUAJIT_LIB;
procedure lua_pushinteger(L: Plua_State; n: lua_Integer); cdecl; external LUAJIT_LIB;
procedure lua_pushlstring(L: Plua_State; const s: PAnsiChar; ls: size_t); cdecl; external LUAJIT_LIB;
procedure lua_pushstring(L: Plua_State; const s: PAnsiChar); cdecl; external LUAJIT_LIB;
function lua_pushvfstring(L: Plua_State; const fmt: PAnsiChar; argp: Pointer): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_pushfstring(L: Plua_State; const fmt: PAnsiChar): PAnsiChar; cdecl; varargs; external LUAJIT_LIB;
procedure lua_pushcclosure(L: Plua_State; fn: lua_CFunction; n: Integer); cdecl; external LUAJIT_LIB;
procedure lua_pushboolean(L: Plua_State; b: Integer); cdecl; external LUAJIT_LIB;
procedure lua_pushlightuserdata(L: Plua_State; p: Pointer); cdecl; external LUAJIT_LIB;
function lua_pushthread(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;

(* get *)
procedure lua_gettable(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_getfield(L: Plua_State; idx: Integer; const k: PAnsiChar); cdecl; external LUAJIT_LIB;
procedure lua_rawget(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_rawgeti(L: Plua_State; idx, n: Integer); cdecl; external LUAJIT_LIB;
procedure lua_createtable(L: Plua_State; narr, nrec: Integer); cdecl; external LUAJIT_LIB;
function lua_newuserdata(L: Plua_State; sz: size_t): Pointer; cdecl; external LUAJIT_LIB;
function lua_getmetatable(L: Plua_State; objindex: Integer): Integer; cdecl; external LUAJIT_LIB;
procedure lua_getfenv(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;

(* set *)
procedure lua_settable(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_setfield(L: Plua_State; idx: Integer; const k: PAnsiChar); cdecl; external LUAJIT_LIB;
procedure lua_rawset(L: Plua_State; idx: Integer); cdecl; external LUAJIT_LIB;
procedure lua_rawseti(L: Plua_State; idx, n: Integer); cdecl; external LUAJIT_LIB;
function lua_setmetatable(L: Plua_State; objindex: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_setfenv(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;

(* call / load *)
procedure lua_call(L: Plua_State; nargs, nresults: Integer); cdecl; external LUAJIT_LIB;
function lua_pcall(L: Plua_State; nargs, nresults, errfunc: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_cpcall(L: Plua_State; func: lua_CFunction; ud: Pointer): Integer; cdecl; external LUAJIT_LIB;
function lua_load(L: Plua_State; reader: lua_Reader; dt: Pointer; const chunkname: PAnsiChar): Integer; cdecl; external LUAJIT_LIB;
function lua_dump(L: Plua_State; writer: lua_Writer; data: Pointer): Integer; cdecl; external LUAJIT_LIB;

(* coroutine *)
function lua_yield(L: Plua_State; nresults: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_resume(L: Plua_State; narg: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_status(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;

(* gc *)
function lua_gc(L: Plua_State; what, data: Integer): Integer; cdecl; external LUAJIT_LIB;

(* misc *)
function lua_error(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;
function lua_next(L: Plua_State; idx: Integer): Integer; cdecl; external LUAJIT_LIB;
procedure lua_concat(L: Plua_State; n: Integer); cdecl; external LUAJIT_LIB;
function lua_getallocf(L: Plua_State; ud: PPointer): lua_Alloc; cdecl; external LUAJIT_LIB;
procedure lua_setallocf(L: Plua_State; f: lua_Alloc; ud: Pointer); cdecl; external LUAJIT_LIB;

(* debug *)
function lua_getstack(L: Plua_State; level: Integer; ar: Plua_Debug): Integer; cdecl; external LUAJIT_LIB;
function lua_getinfo(L: Plua_State; const what: PAnsiChar; ar: Plua_Debug): Integer; cdecl; external LUAJIT_LIB;
function lua_getlocal(L: Plua_State; const ar: Plua_Debug; n: Integer): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_setlocal(L: Plua_State; const ar: Plua_Debug; n: Integer): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_getupvalue(L: Plua_State; funcindex, n: Integer): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_setupvalue(L: Plua_State; funcindex, n: Integer): PAnsiChar; cdecl; external LUAJIT_LIB;
function lua_sethook(L: Plua_State; func: lua_Hook; mask, count: Integer): Integer; cdecl; external LUAJIT_LIB;
function lua_gethook(L: Plua_State): lua_Hook; cdecl; external LUAJIT_LIB;
function lua_gethookmask(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;
function lua_gethookcount(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;

(* LuaJIT / 5.2+ extensions in lua.h *)
function lua_upvalueid(L: Plua_State; idx, n: Integer): Pointer; cdecl; external LUAJIT_LIB;
procedure lua_upvaluejoin(L: Plua_State; idx1, n1, idx2, n2: Integer); cdecl; external LUAJIT_LIB;
function lua_loadx(L: Plua_State; reader: lua_Reader; dt: Pointer; const chunkname, mode: PAnsiChar): Integer; cdecl; external LUAJIT_LIB;
function lua_version(L: Plua_State): Plua_Number; cdecl; external LUAJIT_LIB;
procedure lua_copy(L: Plua_State; fromidx, toidx: Integer); cdecl; external LUAJIT_LIB;
function lua_tonumberx(L: Plua_State; idx: Integer; isnum: PInteger): lua_Number; cdecl; external LUAJIT_LIB;
function lua_tointegerx(L: Plua_State; idx: Integer; isnum: PInteger): lua_Integer; cdecl; external LUAJIT_LIB;
function lua_isyieldable(L: Plua_State): Integer; cdecl; external LUAJIT_LIB;

(* macro-style helpers *)
procedure lua_pop(L: Plua_State; n: Integer); inline;
procedure lua_newtable(L: Plua_State); inline;
procedure lua_register(L: Plua_State; const n: PAnsiChar; f: lua_CFunction); inline;
procedure lua_pushcfunction(L: Plua_State; f: lua_CFunction); inline;
procedure lua_getglobal(L: Plua_State; const s: PAnsiChar); inline;
procedure lua_setglobal(L: Plua_State; const s: PAnsiChar); inline;
function lua_tostring(L: Plua_State; idx: Integer): PAnsiChar; inline;

function lua_strlen(L: Plua_State; idx: Integer): size_t; inline;

function lua_isfunction(L: Plua_State; n: Integer): Boolean; inline;
function lua_istable(L: Plua_State; n: Integer): Boolean; inline;
function lua_islightuserdata(L: Plua_State; n: Integer): Boolean; inline;
function lua_isnil(L: Plua_State; n: Integer): Boolean; inline;
function lua_isboolean(L: Plua_State; n: Integer): Boolean; inline;
function lua_isthread(L: Plua_State; n: Integer): Boolean; inline;
function lua_isnone(L: Plua_State; n: Integer): Boolean; inline;
function lua_isnoneornil(L: Plua_State; n: Integer): Boolean; inline;

implementation

function lua_upvalueindex(i: Integer): Integer;
begin
  Result := LUA_GLOBALSINDEX - i;
end;

procedure lua_pop(L: Plua_State; n: Integer);
begin
  lua_settop(L, -n - 1);
end;

procedure lua_newtable(L: Plua_State);
begin
  lua_createtable(L, 0, 0);
end;

procedure lua_register(L: Plua_State; const n: PAnsiChar; f: lua_CFunction);
begin
  lua_pushcfunction(L, f);
  lua_setglobal(L, n);
end;

procedure lua_pushcfunction(L: Plua_State; f: lua_CFunction);
begin
  lua_pushcclosure(L, f, 0);
end;

procedure lua_getglobal(L: Plua_State; const s: PAnsiChar);
begin
  lua_getfield(L, LUA_GLOBALSINDEX, s);
end;

procedure lua_setglobal(L: Plua_State; const s: PAnsiChar);
begin
  lua_setfield(L, LUA_GLOBALSINDEX, s);
end;

function lua_tostring(L: Plua_State; idx: Integer): PAnsiChar;
begin
  Result := lua_tolstring(L, idx, nil);
end;

function lua_strlen(L: Plua_State; idx: Integer): size_t;
begin
  Result := lua_objlen(L, idx);
end;

function lua_isfunction(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TFUNCTION;
end;

function lua_istable(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TTABLE;
end;

function lua_islightuserdata(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TLIGHTUSERDATA;
end;

function lua_isnil(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TNIL;
end;

function lua_isboolean(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TBOOLEAN;
end;

function lua_isthread(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TTHREAD;
end;

function lua_isnone(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) = LUA_TNONE;
end;

function lua_isnoneornil(L: Plua_State; n: Integer): Boolean;
begin
  Result := lua_type(L, n) <= 0;
end;

end.
