(******************************************************************************
 * LuaJIT — C API extensions (luajit.h): JIT engine control via luaJIT_setmode.
 * Same shared library as luajit51 (LUAJIT_LIB).
 ******************************************************************************)

{$IFDEF FPC}{$MODE OBJFPC}{$H+}{$ENDIF}

unit luajit_ext;

interface

uses
  luajit51;

const
  LUAJIT_MODE_MASK = $00ff;

  LUAJIT_MODE_ENGINE     = 0;
  LUAJIT_MODE_DEBUG      = 1;
  LUAJIT_MODE_FUNC       = 2;
  LUAJIT_MODE_ALLFUNC    = 3;
  LUAJIT_MODE_ALLSUBFUNC = 4;
  LUAJIT_MODE_TRACE      = 5;
  LUAJIT_MODE_WRAPCFUNC  = $10;
  LUAJIT_MODE_MAX        = 6;

  LUAJIT_MODE_OFF   = $0000;
  LUAJIT_MODE_ON    = $0100;
  LUAJIT_MODE_FLUSH = $0200;

function luaJIT_setmode(L: Plua_State; idx, mode: Integer): Integer; cdecl; external LUAJIT_LIB;

implementation

end.
