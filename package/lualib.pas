{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lualib;

{$warn 5023 off : no warning about unused units}
interface

uses
  lua54, lauxlib54, lualib54, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('lualib', @Register);
end.
