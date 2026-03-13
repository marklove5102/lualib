# Руководство по использованию библиотеки Lua 5.4 для Free Pascal

Одни и те же привязки (**lua54**, **lauxlib54**, **lualib54**) подходят для двух сценариев:

1. **Pascal → Lua**: ваша программа на Pascal — **хост**; она создаёт состояние Lua, подключает стандартные библиотеки, загружает и выполняет скрипты, передаёт данные через стек.
2. **Lua → Pascal**: ваш код на Pascal собирается в **DLL** (C-модуль); Lua загружает его через `require()` и вызывает экспортированные функции.

Ниже: как собрать C-модуль для Lua, как вызвать его из Lua, как писать свои модули и **как вызывать Lua из Pascal** (встраивание).

---

## 1. Что нужно установить

| Компонент | Назначение |
|-----------|------------|
| **Free Pascal (FPC)** | Компилятор. Рекомендуется установка через [fpcupdeluxe](https://github.com/LongDirtyAnimAlf/fpcupdeluxe), путь вида `C:\fpcupdeluxe`. |
| **Lua 5.4** | Интерпретатор (`lua` или `lua54`) и библиотека **lua54.dll** (Windows) или **liblua.so.5.4** (Unix). Версия Lua должна быть 5.4. |

Модуль (DLL), собранный с этими привязками, подгружается из Lua через `require()` и вызывает функции из той же lua54.dll, с которой собран интерпретатор.

### 1.1. Где и как ищется lua54.dll

Ищет библиотеку **не** ваш код и **не** Lua, а загрузчик ОС (на Windows — стандартный поиск DLL при загрузке exe или другой DLL). Имя берётся из привязок: в `lua54.pas` задана константа `LUA54_LIB = 'lua54.dll'` (на Unix — `liblua.so.5.4`). Компилятор подставляет её в импорт, и при запуске exe или при загрузке вашей DLL загрузчик ищет эту библиотеку.

**Порядок поиска на Windows** (упрощённо):

1. Каталог исполняемого файла процесса (для хоста — каталог вашего exe; для C-модуля — каталог **lua.exe**, т.к. процесс запущен им).
2. Системный каталог Windows (например `System32`).
3. Каталог Windows (например `C:\Windows`).
4. Текущая рабочая директория (текущий каталог при запуске).
5. Каталоги из переменной окружения **PATH**.

**Практически:**

- **Хост на Pascal** (например `run_lua.exe`): положите **lua54.dll** в тот же каталог, что и `run_lua.exe`, или добавьте каталог с lua54.dll в **PATH**.
- **C-модуль (mymodule.dll), вызываемый из Lua**: процесс — это `lua.exe`. Загрузка `mymodule.dll` приводит к загрузке `lua54.dll`; ищется она относительно **lua.exe**. Положите **lua54.dll** в каталог с `lua.exe` или в **PATH**.

Изменить имя библиотеки (например на `lua54-dev.dll`) можно в `src/lua54.pas`: константа **LUA54_LIB**. После изменения пересоберите и хост, и все свои C-модули.

**Linux/Unix:** привязки под Unix используют **LUA54_LIB = 'liblua.so.5.4'** (в `lua54.pas` — `{$IFDEF UNIX}`). Ищет библиотеку загрузчик (ld.so): каталоги из **LD_LIBRARY_PATH**, затем `/lib`, `/usr/lib` и т.д. Хост или ваш C-модуль (.so) должны находить liblua.so.5.4 (установите пакет liblua5.4-dev или соберите Lua из исходников).

---

## 2. Быстрый старт: пример mymodule

### 2.1. Сборка модуля

В корне проекта (`d:\projects\pascal\lualib`):

```batch
build.cmd
```

или в PowerShell:

```powershell
.\build.ps1
```

В результате в каталоге `example\` появится **mymodule.dll**.

### 2.2. Запуск из Lua

Перейдите в каталог с DLL и скриптом:

```batch
cd example
lua test_mymodule.lua
```

(Команда может называться `lua`, `lua54` или `lua5.4` — в зависимости от установки.)

Ожидаемый вывод: `Hello from Pascal!`

Скрипт `test_mymodule.lua` сам добавляет текущий каталог и каталог скрипта в `package.cpath`, чтобы Lua нашла модуль (на Windows — `mymodule.dll`, на Linux — `mymodule.so`) без дополнительных настроек.

### 2.3. Если модуль не находится

- Убедитесь, что **mymodule.dll** (Windows) или **mymodule.so** (Linux) лежит в том же каталоге, что и `test_mymodule.lua`, или добавьте этот каталог в `package.cpath` (в скрипте это уже сделано для каталога скрипта и текущего каталога).
- Убедитесь, что в PATH или рядом с `lua.exe` есть **lua54.dll** (Windows); на Linux — **liblua.so.5.4** в LD_LIBRARY_PATH или в системных каталогах. Без неё загрузка модуля завершится ошибкой.

### 2.4. Сборка и запуск на Linux

На Linux привязки используют **liblua.so.5.4** (см. §1.1). Сборка примера:

```bash
cd /path/to/lualib
chmod +x build.sh
./build.sh
```

В каталоге `example/` появится **mymodule.so**. Запуск:

```bash
cd example
lua test_mymodule.lua
```

Убедитесь, что установлены FPC и Lua 5.4 (и при необходимости пакет вроде `liblua5.4-dev` или собранная из исходников liblua.so.5.4). Если библиотека Lua не в системном пути — задайте `export LD_LIBRARY_PATH=/path/to/lua/lib:$LD_LIBRARY_PATH`.

---

## 3. Использование своего модуля из Lua

После сборки вашей библиотеки (например, `mymodule.dll`):

1. Положите DLL в каталог, который Lua ищет по `package.cpath`, **или** в начале скрипта добавьте этот каталог в `package.cpath` (как в `test_mymodule.lua`).
2. Вызовите модуль по имени (без расширения `.dll`):

```lua
local m = require('mymodule')
m.hello()
```

Имя в `require('mymodule')` должно соответствовать имени функции входа в DLL: `luaopen_mymodule`. Точки в имени модуля в C заменяются на подчёркивание (например, `require('a.b')` → ищется `luaopen_a_b`).

---

## 4. Написание своего C-модуля на Pascal

### 4.1. Структура проекта

- Исходник — **library**, не program.
- В секции `uses` подключайте `lua54` и `lauxlib54`.
- Путь к папке `src` задаётся при компиляции через `-Fu"путь\к\src"`.

### 4.2. Функция, вызываемая из Lua

Сигнатура любой функции, которую вы регистрируете в Lua:

```pascal
function my_func(L: Plua_State): Integer; cdecl;
```

- **L** — состояние Lua (стек, регистр и т.д.).
- Возвращаемое значение — **число возвращаемых значений** на стеке (0, 1, 2, …).
- Обязательно **cdecl** — соглашение вызова C.

Аргументы берутся со стека по индексам (1 — первый аргумент, 2 — второй и т.д.). Результаты кладутся на стек, начиная с вершины.

Пример: функция без аргументов, возвращающая строку:

```pascal
function my_hello(L: Plua_State): Integer; cdecl;
begin
  lua_pushstring(L, 'Hello from Pascal!');
  Result := 1;
end;
```

Пример: функция, принимающая число и строку, возвращающая число:

```pascal
function my_add(L: Plua_State): Integer; cdecl;
var
  a, b: Integer;
begin
  a := lua_tointeger(L, 1);   // первый аргумент
  b := lua_tointeger(L, 2);   // второй аргумент
  lua_pushinteger(L, a + b);
  Result := 1;
end;
```

### 4.3. Точка входа модуля: luaopen_<имя>

Lua при `require('mymodule')` ищет в DLL функцию **luaopen_mymodule** (для подмодулей точки заменяются на `_`). Она должна:

1. Проверить версию Lua: `luaL_checkversion(L)`.
2. Создать таблицу: `lua_createtable(L, 0, N)` (N — ориентировочное число полей).
3. Зарегистрировать в ней C-функции через `luaL_setfuncs(L, @lib[0], 0)`.
4. Вернуть `1` (одна возвращаемая величина — таблица).

Пример полной точки входа:

```pascal
function luaopen_mymodule(L: Plua_State): Integer; cdecl;
const
  lib: array[0..2] of luaL_Reg = (
    (name: 'hello'; func: @my_hello),
    (name: 'add';   func: @my_add),
    (name: nil;     func: nil)   // признак конца массива
  );
begin
  luaL_checkversion(L);
  lua_createtable(L, 0, 2);
  luaL_setfuncs(L, @lib[0], 0);
  Result := 1;
end;
```

### 4.4. Экспорт точки входа из DLL

В конце исходника библиотеки:

```pascal
exports
  luaopen_mymodule name 'luaopen_mymodule';
end.
```

Имя в `name '...'` должно точно совпадать с тем, что ищет Lua (`luaopen_<модуль>`).

### 4.5. Сборка

Из командной строки (Windows, x86_64), из корня проекта:

```batch
"C:\fpcupdeluxe\fpc\bin\x86_64-win64\fpc.exe" -MObjFPC -Scghi -O2 -Twin64 -Px86_64 -Fu"src" -Fi"src" example\mymodule.lpr
```

Или скопируйте вызов из `build.cmd` / `build.ps1`, заменив имя проекта на свой.

---

## 5. Основные функции API (кратко)

### 5.1. Стек (lua54.pas)

| Функция | Назначение |
|---------|------------|
| `lua_gettop(L)` | Количество элементов на стеке. |
| `lua_settop(L, idx)` | Обрезать/расширить стек до индекса. |
| `lua_pushstring(L, s)` | Кладёт строку на стек. |
| `lua_pushinteger(L, n)` | Кладёт целое на стек. |
| `lua_pushnumber(L, n)` | Кладёт число (lua_Number) на стек. |
| `lua_pushboolean(L, b)` | Кладёт булево на стек. |
| `lua_pushnil(L)` | Кладёт nil. |
| `lua_tostring(L, idx)` | Строка по индексу (или nil). |
| `lua_tointeger(L, idx)` | Целое по индексу. |
| `lua_tonumber(L, idx)` | Число по индексу. |
| `lua_toboolean(L, idx)` | Булево по индексу. |
| `lua_type(L, idx)` | Тип значения (LUA_TNUMBER, LUA_TSTRING и т.д.). |
| `lua_pop(L, n)` | Удалить n элементов с вершины стека. |

### 5.2. Вспомогательные (lauxlib54.pas)

| Функция | Назначение |
|---------|------------|
| `luaL_checkversion(L)` | Проверка версии Lua (вызвать в luaopen_*). |
| `luaL_checkstring(L, arg)` | Строка по номеру аргумента или ошибка. |
| `luaL_checkinteger(L, arg)` | Целое по номеру аргумента или ошибка. |
| `luaL_checknumber(L, arg)` | Число по номеру аргумента или ошибка. |
| `luaL_optstring(L, arg, def)` | Строка или значение по умолчанию. |
| `luaL_optinteger(L, arg, def)` | Целое или значение по умолчанию. |
| `luaL_error(L, fmt, ...)` | Вызвать ошибку Lua с сообщением. |
| `luaL_setfuncs(L, reg, nup)` | Регистрация массива функций в таблице на вершине стека. |

Полный список объявлений — в исходниках `src/lua54.pas` и `src/lauxlib54.pas`.

---

## 6. Частые проблемы

| Проблема | Что проверить |
|----------|----------------|
| **module 'mymodule' not found** | DLL не в `package.cpath`. Добавьте каталог с DLL в `package.cpath` (как в `test_mymodule.lua`) или положите DLL в каталог, уже указанный в cpath. |
| **Ошибка при загрузке DLL** (например, "The specified module could not be found") | Не найдена **lua54.dll**. Загрузчик ищет её по стандартному порядку (каталог exe процесса, затем PATH). Положите lua54.dll в каталог **lua.exe** (при вызове из Lua) или рядом с вашим exe (хост). Подробнее — §1.1 «Где и как ищется lua54.dll». |
| **Несовместимая версия / краш** | Модуль должен быть собран с той же разрядностью (32/64) и с той же lua54.dll (или совместимой 5.4), с которой запущен интерпретатор. |
| **Имя luaopen_* не совпадает** | В `require('name')` имя должно соответствовать функции `luaopen_name` (точки в имени модуля → `_` в имени функции). |

---

## 7. Вызов Lua из Pascal (хост)

Если вы пишете **программу на Pascal**, которая сама запускает Lua (интерпретатор, плагины, скрипты), используйте те же единицы: **lua54**, **lauxlib54** и **lualib54**.

### 7.1. Минимальный скелет

```pascal
program myhost;
uses lua54, lauxlib54, lualib54;

var
  L: Plua_State;

begin
  L := luaL_newstate;      // создать состояние Lua
  if L = nil then Halt(1);
  try
    luaL_openlibs(L);      // подключить стандартные библиотеки (base, string, table, ...)
    // Загрузить и выполнить файл:
    if luaL_loadfile(L, 'script.lua') <> LUA_OK then
      writeln(lua_tostring(L, -1))
    else if lua_pcall(L, 0, 0, 0) <> LUA_OK then
      writeln(lua_tostring(L, -1));
    // Или выполнить строку:
    // luaL_dostring(L, 'print("Hello from Lua")');
  finally
    lua_close(L);
  end;
end.
```

Сборка (исполняемый файл, не DLL):  
`fpc -Fu"src" -Fi"src" myhost.lpr`

Рядом с получившимся exe должна быть **lua54.dll** (или в PATH).

### 7.2. Вызов функции Lua из Pascal

Загрузите скрипт (или код), затем поместите на стек имя функции, аргументы и вызовите:

```pascal
lua_getglobal(L, 'myfunc');   // функция по имени
lua_pushinteger(L, 42);      // первый аргумент
lua_pushstring(L, 'test');    // второй аргумент
if lua_pcall(L, 2, 1, 0) = LUA_OK then
  writeln('Result: ', lua_tointeger(L, -1));
lua_pop(L, 1);
```

### 7.3. Регистрация своей функции для вызова из Lua

Чтобы скрипт мог вызывать вашу Pascal-функцию, зарегистрируйте её в глобальной таблице или в своей таблице:

```pascal
function my_callback(L: Plua_State): Integer; cdecl;
begin
  writeln('Called from Lua with: ', lua_tointeger(L, 1));
  lua_pushstring(L, 'ok');
  Result := 1;
end;

// После luaL_openlibs:
lua_register(L, 'my_callback', @my_callback);
```

В Lua: `my_callback(123)` — вызовет вашу функцию.

### 7.4. Коллбеки: вызов Lua из Pascal и передача функций

Полный пример в каталоге **example/**:

- **callbacks.lpr** — хост, который регистрирует функции для вызова из Lua и для вызова Lua из Pascal.
- **callbacks_demo.lua** — скрипт, который их использует.

Запуск: `callbacks callbacks_demo.lua` (сборка: `fpc -Fu"../src" -Fi"../src" callbacks.lpr` из каталога example).

| Действие | Как |
|----------|-----|
| **Lua вызывает Pascal** | Регистрируйте C-функцию через `lua_register` или `luaL_setfuncs`; в Lua вызывайте по имени (как в mymodule). |
| **Lua передаёт функцию в Pascal** | В C-функции аргумент с индексом 1 — функция: `luaL_checktype(L, 1, LUA_TFUNCTION)`. Сохранить в реестре: `lua_pushvalue(L, 1); ref := luaL_ref(L, LUA_REGISTRYINDEX)`. |
| **Pascal вызывает переданную Lua-функцию** | Функция на стеке (индекс 1), аргументы — 2, 3, …; подготовить стек: функция на вершине, под ней аргументы; вызвать `lua_pcall(L, nargs, LUA_MULTRET, 0)`. Удобно: `lua_rotate(L, 1, nargs)` сдвигает функцию на вершину. |
| **Pascal вызывает сохранённую ранее функцию** | `lua_rawgeti(L, LUA_REGISTRYINDEX, ref)`, затем положить аргументы, затем `lua_pcall(L, nargs, nresults, 0)`. |

В **callbacks.lpr** реализовано:

- **pascal.call_lua_func(func, ...)** — Pascal вызывает переданную Lua-функцию с аргументами и возвращает её результаты.
- **pascal.store_callback(func)** — сохранить Lua-функцию в реестре (для последующего вызова из Pascal).
- **pascal.invoke_stored()** — вызвать сохранённую функцию (без аргументов).
- **pascal.pascal_side_calc(a, b)** — пример: Pascal-функция, которая при наличии сохранённого коллбека вызывает его с результатом a+b.

Пример хоста, который только запускает скрипт: **example/run_lua.lpr**.

---

## 8. Использование в Lazarus (пакет lualib.lpk)

**Что нужно знать, чтобы пользоваться в Lazarus:**

| Что | Замечание |
|-----|------------|
| **Где пакет** | Файл `package/lualib.lpk` в корне репозитория. Открывать именно его (Package → Open package file). |
| **Сначала скомпилировать пакет** | В окне пакета нажать **Compile**, затем **Use** → **Install**. После Install пакет доступен во всех проектах. |
| **Подключение к проекту** | Project → Project Inspector → Add → New requirement → выбрать **lualib**. |
| **В коде** | `uses lua54, lauxlib54, lualib54;` (lualib54 — только для хоста; для DLL-модуля достаточно lua54, lauxlib54). |
| **Библиотека Lua** | Рядом с вашим exe/DLL нужна **lua54.dll** (Windows) или **liblua.so.5.4** в PATH/LD_LIBRARY_PATH. Без неё приложение упадёт при загрузке. |
| **DLL-модуль для Lua** | Создавать проект типа **Library**, экспортировать `luaopen_<имя>`. Имя DLL — как у модуля для `require()`. |
| **Без установки в IDE** | Можно не нажимать Install: открыть lualib.lpk и в своём проекте добавить зависимость Add → Add required package → lualib. |
| **Скрипты сборки** | При работе из Lazarus скрипты **build.sh**, **build_run_lua.sh**, **build.cmd** и т.д. **не нужны** — сборка идёт через Run/Build в IDE. Скрипты имеют смысл для командной строки, CI или если не используете Lazarus. |

Путь к пакету: Windows — например `d:\projects\pascal\lualib\package\lualib.lpk`, Linux — например `/home/user/lualib/package/lualib.lpk`. Относительные пути в .lpk (`..\src`) Lazarus обрабатывает на обеих ОС.

Ниже — пошаговые шаги.

### 8.1. Установка пакета

1. Откройте Lazarus.
2. **Package** → **Open package file (.lpk)**.
3. Укажите файл пакета: `d:\projects\pascal\lualib\package\lualib.lpk` (или путь к вашему клону репозитория).
4. В окне редактора пакета нажмите **Compile** (компиляция только пакета).
5. Нажмите **Use** → **Install**. Пакет будет скомпилирован и зарегистрирован в IDE. Перезапуск Lazarus может потребоваться, если IDE попросит.

После установки пакет **lualib** появляется в списке доступных пакетов, и его единицы (lua54, lauxlib54, lualib54) можно использовать в любом проекте, добавив зависимость от lualib.

### 8.2. Подключение пакета к своему проекту

1. **Project** → **Project Inspector** (или **View** → **Project Inspector**).
2. Нажмите **Add** → **New requirement**.
3. Выберите пакет **lualib** → OK.

Теперь в коде проекта можно писать `uses lua54, lauxlib54, lualib54;` — пути к исходникам подхватятся автоматически.

### 8.3. Сборка проекта (программа или DLL)

- **Обычная программа (хост):** создайте Application или Program, добавьте зависимость lualib, в коде используйте `lua54`, `lauxlib54`, `lualib54`. Собирайте как обычно (Run / Build). Рядом с exe должна быть **lua54.dll**.
- **C-модуль (DLL):** создайте **Library** (File → New → Library), добавьте зависимость lualib, реализуйте `luaopen_<имя>` и экспортируйте её в **Project Options** → **Compiler Options** → **Linking** → **Export** (или в коде `exports ...`). Соберите проект; рядом с получившейся DLL должна быть **lua54.dll** при запуске из Lua.

### 8.4. Если пакет не ставится глобально

Если не хотите ставить пакет в IDE через Install, можно подключать его только к нужным проектам:

1. **Package** → **Open package file** → выберите `lualib.lpk`.
2. Не нажимайте Install. Оставьте окно пакета открытым или закройте — пакет остаётся в списке открытых.
3. В своём проекте: **Project** → **Project Inspector** → **Add** → **Add required package** → выберите **lualib**.

Проект будет компилироваться с единицами lualib; путь к исходникам пакета задаётся самим пакетом (`Other unit files` → `..\src`).

---

## 9. Дополнительно

- **lualib54.pas** нужен для **хоста** (вызов Lua из Pascal): в нём `luaL_openlibs` и `luaopen_*`. Для одного только C-модуля (DLL для `require`) достаточно **lua54** и **lauxlib54**.
- Имя DLL Lua в привязках задаётся константой **LUA54_LIB** в `lua54.pas` (по умолчанию `lua54.dll` на Windows). Если у вас библиотека называется иначе — измените эту константу и пересоберите.
