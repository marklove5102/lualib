-- Демо: вызов коллбеков между Pascal и Lua.
-- Запуск: callbacks callbacks_demo.lua  (или callbacks.exe из example)

print("=== 1) Lua вызывает функции Pascal (pascal.*) ===")
local sum = pascal.pascal_side_calc(10, 20)
print("pascal.pascal_side_calc(10, 20) = " .. sum)

print("\n=== 2) Lua передаёт функцию в Pascal (store_callback), Pascal потом её вызывает (invoke_stored) ===")
pascal.store_callback(function(x)
  print("  [Lua callback] вызван из Pascal, аргумент: " .. tostring(x))
end)
-- Эмулируем "позже": Pascal вызывает сохранённую функцию
print("Pascal вызывает сохранённую функцию:")
pascal.invoke_stored()

print("\n=== 3) Pascal вызывает переданную Lua-функцию с аргументами (call_lua_func) ===")
local function add(a, b)
  return a + b
end
local r1, r2 = pascal.call_lua_func(add, 3, 5)
print("pascal.call_lua_func(add, 3, 5) = " .. tostring(r1) .. (r2 and ", " .. tostring(r2) or ""))

local function multi_return()
  return 1, "two", true
end
local a, b, c = pascal.call_lua_func(multi_return)
print("pascal.call_lua_func(multi_return) = " .. tostring(a) .. ", " .. tostring(b) .. ", " .. tostring(c))

print("\n=== 4) Коллбек при вызове pascal_side_calc ===")
-- Сохраняем коллбек, который будет вызван из pascal_side_calc с результатом a+b
pascal.store_callback(function(s)
  print("  [Lua] Получили от Pascal результат: " .. tostring(s))
end)
print("pascal.pascal_side_calc(1, 2) (Pascal вызовет наш коллбек с 3):")
local s = pascal.pascal_side_calc(1, 2)
print("  Возврат в Lua: " .. s)

print("\n=== Готово ===")
