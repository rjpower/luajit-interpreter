local string = require('string')

local JUMP_IF_A  = 1
local MOV_A_R  = 2
local MOV_R_A  = 3
local ADD_R_TO_A = 4
local DECR_A   = 5
local RETURN_A   = 6

local function jit_interpret(bytecode, a)
  f_str = [[
function _jit(a)
  local reg = {
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  }
  ]]

  local pc = 1
  while pc < #bytecode + 1 do
    local opcode = bytecode[pc]
    f_str = f_str .. string.format('::op_%d::\n', pc)
    pc = pc + 1

    if opcode == JUMP_IF_A then
      local target = bytecode[pc]
      pc = pc + 1
      f_str = f_str .. string.format([[
if a == 0 then
  goto op_%d
end
goto op_%d
]], pc, target)
    elseif opcode == MOV_R_A then
      local n = bytecode[pc]
      pc = pc + 1
    f_str = f_str .. string.format([[
a = reg[%d]
]], n)
    elseif opcode == MOV_A_R then
      local n = bytecode[pc]
      pc = pc + 1
    f_str = f_str .. string.format([[
reg[%d] = a
]], n)
    elseif opcode == ADD_R_TO_A then
      local n = bytecode[pc]
      pc = pc + 1
      f_str = f_str .. string.format([[
a = a + reg[%d]
]], n)
    elseif opcode == DECR_A then
      f_str = f_str .. string.format([[
a = a - 1
]])
    elseif opcode == RETURN_A then
      f_str = f_str .. string.format([[
return a
]])
    end
  end

f_str = f_str .. 'end\n'

loadstring(f_str)()
return _jit(a)
end

-- __________  Entry point  __________
local function entry_point(argv)
  -- the program we want to interpret
  -- it computes the square of its argument
  bytecode = {
    MOV_A_R,  1, -- i = a
    MOV_A_R,  2, -- copy of 'a'
    -- 5:
    MOV_R_A,  1, -- i--
    DECR_A,
    MOV_A_R,  1,
    MOV_R_A,  3, -- res += a
    ADD_R_TO_A, 2,
    MOV_A_R,  3,
    MOV_R_A,  1, -- if i!=0: goto 5
    JUMP_IF_A,  5,
    MOV_R_A,  3,
    RETURN_A
  }
  -- result = interpret(bytecode, tonumber(argv[1]))
  result = jit_interpret(bytecode, tonumber(argv[1]))
  print(result)
end

-- main function
entry_point(arg)
