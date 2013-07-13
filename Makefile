PYPY_PATH ?= /usr/local/pypy
COUNT ?= 10000000

toy-pypy-c : toy-pypy.py
	PYTHONPATH=$(PYPY_PATH)/ $(PYPY_PATH)/rpython/translator/goal/translate.py $^

timings: toy-pypy-c
	time ./toy-pypy-c bytecode.str $(COUNT)
	time luajit toy.lua $(COUNT)
	time luajit toy-jit.lua $(COUNT)
	time python toy-python.py bytecode.str $(COUNT)
