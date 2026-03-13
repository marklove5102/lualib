# Pascal bindings to Lua 5.4 C API

Free Pascal units to build **dynamic libraries (C modules)** loadable from Lua 5.4 via `require()`.

- **lua54.pas** — Lua 5.4 core API (lua.h)
- **lauxlib54.pas** — Auxiliary library (lauxlib.h)
- **lualib54.pas** — Standard libraries (lualib.h), optional, for embedding a Lua host in Pascal

Compiler: Free Pascal (e.g. from [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe) in `C:\fpcupdeluxe`).

Одни и те же единицы используются для **двух сценариев**: (1) вызов Lua из Pascal — программа-хост создаёт состояние, подключает библиотеки, выполняет скрипты; (2) вызов Pascal из Lua — ваш код в виде DLL загружается через `require()`.

**Подробная документация:** [docs/USAGE.md](docs/USAGE.md) — как пользоваться библиотекой, писать свои модули, встраивать Lua в приложение, **подключить пакет в Lazarus** ([package/lualib.lpk](package/lualib.lpk)), решать типичные проблемы.

## Requirements

- Free Pascal (FPC) 3.0+
- Lua 5.4: interpreter and **lua54.dll** (Windows) or **liblua.so.5.4** (Unix).  
  Your module DLL will link to this library; the Lua executable must use the same library.  
  The OS loader looks for **lua54.dll** (name is set in `lua54.pas` as `LUA54_LIB`): first the directory of the process exe (e.g. lua.exe when running from Lua, or your exe when running a host), then system dirs and **PATH**. See [docs/USAGE.md](docs/USAGE.md) §1.1.

## Directory layout

```
lualib/
  src/
    lua54.pas      — core API
    lauxlib54.pas  — auxiliary
    lualib54.pas   — standard libs (optional)
  example/
    mymodule.lpr         — пример C-модуля для Lua (DLL)
    run_lua.lpr          — пример хоста (запуск скрипта)
    callbacks.lpr        — коллбеки: вызов Lua из Pascal и передача функций
    callbacks_demo.lua   — демо для callbacks
    test_mymodule.lua    — вызов mymodule из Lua
  package/
    lualib.lpk    — пакет Lazarus (подключение в IDE)
  docs/
    USAGE.md       — руководство по использованию
  build.cmd        — сборка примера (Windows x86_64)
  build.sh         — сборка примера (Linux/Unix)
  build.ps1        — сборка примера (PowerShell)
  README.md
```

## Building the example module

From the project root:

```batch
build.cmd
```

Or with PowerShell:

```powershell
.\build.ps1
```

Or manually (x86_64 Windows):

```batch
fpc -MObjFPC -Scghi -O2 -Twin64 -Px86_64 -Fu"src" -Fi"src" example\mymodule.lpr
```

For 32-bit Windows use `-Ti386-win32 -Pi386` and ensure `lua54.dll` is 32-bit.

**Linux:** run `./build.sh` (requires FPC and liblua.so.5.4). Output: **example/mymodule.so**. Use `lua test_mymodule.lua` from the example directory; the script supports both `.dll` (Windows) and `.so` (Linux).

Output (Windows): **example\mymodule.dll**.

## Using the module from Lua 5.4

1. Put **mymodule.dll** in a directory listed in `package.cpath` (e.g. same folder as `lua54.exe` or `.;./?.dll`).
2. Ensure **lua54.dll** is in the same directory as the Lua executable or in `PATH`.
3. В Lua или запустите пример:

```lua
local m = require('mymodule')
print(m.hello())   -- Hello from Pascal!
```

Из каталога `example` (если `mymodule.dll` и `lua54.dll` там же или в PATH):

```batch
lua54 test_mymodule.lua
```

## Creating your own module

1. Create a **library** project (not program):

   ```pascal
   library myname;
   uses lua54, lauxlib54;
   ```

2. Implement one or more C-callable functions:

   ```pascal
   function my_func(L: Plua_State): Integer; cdecl;
   begin
     lua_pushstring(L, 'result');
     Result := 1;   // number of return values
   end;
   ```

3. Export the opener. Lua looks for `luaopen_<module>` (dots in module name become `_`):

   ```pascal
   function luaopen_myname(L: Plua_State): Integer; cdecl;
   const
     lib: array[0..1] of luaL_Reg = (
       (name: 'my_func'; func: @my_func),
       (name: nil; func: nil)
     );
   begin
     luaL_checkversion(L);
     lua_createtable(L, 0, 1);
     luaL_setfuncs(L, @lib[0], 0);
     Result := 1;
   end;

   exports
     luaopen_myname name 'luaopen_myname';
   ```

4. Build with `-Fu` pointing to the folder containing `lua54.pas` and `lauxlib54.pas`.

## Using from Lazarus

Open **package/lualib.lpk** in Lazarus, then **Compile** and **Use** → **Install**. In your project: **Project** → **Project Inspector** → **Add** → **New requirement** → choose **lualib**. Then `uses lua54, lauxlib54, lualib54;` in code. When using Lazarus, **no build scripts are needed** — use Run/Build in the IDE. See [docs/USAGE.md](docs/USAGE.md) §8.

## Embedding Lua in a Pascal program (host)

Use **lua54**, **lauxlib54** and **lualib54**. Create state with `luaL_newstate`, then `luaL_openlibs(L)`, then load/run scripts with `luaL_loadfile`/`lua_pcall` or `luaL_loadstring`/`lua_pcall`. See [docs/USAGE.md](docs/USAGE.md) §7 and **example/run_lua.lpr**.

Build the example host (from project root):

```batch
fpc -Fu"src" -Fi"src" example\run_lua.lpr
```

Run: `run_lua` (runs a built-in Lua snippet) or `run_lua script.lua`. Place **lua54.dll** next to the exe or in PATH.

## Configuring the Lua library name

If your Lua 5.4 shared library has a different name, set the unit constant before use. In **lua54.pas** the default is:

- Windows: `lua54.dll`
- Unix: `liblua.so.5.4`

You can define a custom name at compile time, or copy `lua54.pas` and change `LUA54_LIB` in the `const` section.

## License

Same as Lua: MIT. Pascal bindings and example are provided as-is.
