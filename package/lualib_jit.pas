{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lualib_jit;

{$warn 5023 off : no warning about unused units}
interface

uses
  luajit51, lauxlib51, lualib51, luajit_ext, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lualib_jit', @Register);
end.
