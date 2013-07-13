import os, sys
import py
 
# these are the opcodes for the interpreted language
JUMP_IF_A  = 1
MOV_A_R    = 2
MOV_R_A    = 3
ADD_R_TO_A = 4
DECR_A     = 5
RETURN_A   = 6
 
from rpython.rlib.jit import JitDriver
from rpython.rlib import streamio
tlrjitdriver = JitDriver(greens = ['pc', 'bytecode'], reds = ['a', 'regs'])
 
# the main interpreter loop
def interpret(bytecode, a):
   regs = [0] * 256
   pc = 0
   while True:
       tlrjitdriver.jit_merge_point(bytecode=bytecode, pc=pc, a=a, regs=regs)
       opcode = bytecode[pc]
       pc += 1
       if opcode == JUMP_IF_A:
           target = bytecode[pc]
           pc += 1
           if a:
             if target < pc:
               tlrjitdriver.can_enter_jit(bytecode=bytecode, pc=target, a=a, regs=regs)                
             pc = target
       elif opcode == MOV_A_R:
           n = bytecode[pc]
           pc += 1
           regs[n] = a
       elif opcode == MOV_R_A:
           n = bytecode[pc]
           pc += 1
           a = regs[n]
       elif opcode == ADD_R_TO_A:
           n = bytecode[pc]
           pc += 1
           a += regs[n]
       elif opcode == DECR_A:
           a -= 1
       elif opcode == RETURN_A:
           return a
 
def strip(w):
  start = 0
  while start < len(w):
    if w[start] == ' ' or w[start] == '\n': start += 1
    else: break

  end = len(w) - 1
  while end > start:
    if w[end] == ' ' or w[end] == '\n': end -= 1
    else: break

  end = max(end, 0)
  return w[start:end + 1]

# __________  Entry point  __________
def entry_point(argv):
    bytecode_str = streamio.open_file_as_stream(argv[1]).readall()
    bytecode_list = [strip(w) for w in bytecode_str.split(',')]

    bytecode = []
    for i, w in enumerate(bytecode_list):
      print "%d : '%s'" % (i, w)

      if w == '': continue

      if w == 'JUMP_IF_A': bytecode.append(JUMP_IF_A)
      elif w == 'MOV_A_R': bytecode.append(MOV_A_R)
      elif w == 'MOV_R_A': bytecode.append(MOV_R_A)
      elif w == 'ADD_R_TO_A': bytecode.append(ADD_R_TO_A)
      elif w == 'DECR_A': bytecode.append(DECR_A)
      elif w == 'RETURN_A': bytecode.append(RETURN_A)
      else: bytecode.append(int(w))

    print bytecode
    result = interpret(bytecode, int(argv[2]))
    print result
    return 0
 
def jitpolicy(driver):
    from pypy.jit.metainterp.policy import JitPolicy
    return JitPolicy()
 
# _____ Define and setup target ___
def target(*args):
    return entry_point, None
 
# main function, if this script is called from the command line
if __name__ == '__main__':
    entry_point(sys.argv)
