local JUMP_IF_A  = 1
local MOV_A_R    = 2
local MOV_R_A    = 3
local ADD_R_TO_A = 4
local DECR_A     = 5
local RETURN_A   = 6

-- the main interpreter loop
local function interpret (bytecode, a)
    local regs = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    }
    local pc = 1
    while true do
        local opcode = bytecode[pc]
        pc = pc + 1
        if opcode == JUMP_IF_A then
            local target = bytecode[pc]
            pc = pc + 1
            if a ~= 0 then
                pc = target
            end
        elseif opcode == MOV_A_R then
            local n = bytecode[pc]
            pc = pc + 1
            regs[n] = a
        elseif opcode == MOV_R_A then
            local n = bytecode[pc]
            pc = pc + 1
            a = regs[n]
        elseif opcode == ADD_R_TO_A then
            local n = bytecode[pc]
            pc = pc + 1
            a = a + regs[n]
        elseif opcode == DECR_A then
            a = a - 1
        elseif opcode == RETURN_A then
            return a
        end
    end
end

-- __________  Entry point  __________
local function entry_point(argv)
    -- the program we want to interpret
    -- it computes the square of its argument
    bytecode = {
        MOV_A_R,    1, -- i = a
        MOV_A_R,    2, -- copy of 'a'
        -- 5:
        MOV_R_A,    1, -- i--
        DECR_A,
        MOV_A_R,    1,
        MOV_R_A,    3, -- res += a
        ADD_R_TO_A, 2,
        MOV_A_R,    3,
        MOV_R_A,    1, -- if i!=0: goto 5
        JUMP_IF_A,  5,
        MOV_R_A,    3,
        RETURN_A
    }
    result = interpret(bytecode, tonumber(argv[1]))
    print(result)
end

-- main function
entry_point(arg)
