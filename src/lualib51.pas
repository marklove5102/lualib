(******************************************************************************
 * LuaJIT — Standard libraries (lualib.h); embedding host via luaL_openlibs.
 ******************************************************************************)

{$IFDEF FPC}{$MODE OBJFPC}{$H+}{$ENDIF}

unit lualib51;

interface

uses
  luajit51;

const
  LUAJIT_STD_LIB = luajit51.LUAJIT_LIB;

  LUA_FILEHANDLE  = 'FILE*';
  LUA_COLIBNAME   = 'coroutine';
  LUA_MATHLIBNAME = 'math';
  LUA_STRLIBNAME  = 'string';
  LUA_TABLIBNAME  = 'table';
  LUA_IOLIBNAME   = 'io';
  LUA_OSLIBNAME   = 'os';
  LUA_LOADLIBNAME = 'package';
  LUA_DBLIBNAME   = 'debug';
  LUA_BITLIBNAME  = 'bit';
  LUA_JITLIBNAME  = 'jit';
  LUA_FFILIBNAME  = 'ffi';

function luaopen_base(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_math(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_string(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_table(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_io(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_os(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_package(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_debug(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_bit(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_jit(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_ffi(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;
function luaopen_string_buffer(L: Plua_State): Integer; cdecl; external LUAJIT_STD_LIB;

procedure luaL_openlibs(L: Plua_State); cdecl; external LUAJIT_STD_LIB;

implementation

end.
