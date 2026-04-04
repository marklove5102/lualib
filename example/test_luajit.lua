-- Запуск: ./run_luajit test_luajit.lua (из каталога example)
print("LuaJIT script OK")
if jit then
  print(jit.version)
else
  print("no global jit")
end
