# Experimenting with / learning different ways to speed up my Master's python simulation

## Methods
- Caching: *Effective caching Road.tt()*
- PyPy: *Great cProfile performace, no Pandas support for data export/check*
- Numba: *Unsuccessful: uses custom classes in tt()* 
- Julia: *Good performance in CLI, great performance in REPL*
- Cython: *TODO*

## Timings
- Base *original code*: ~ 60s
- Caching: ~ 30s
- PyPy: ~ 11s *no data record*
- Numba: ~ 90s - *cannot jit tt()*
- Juila: ~ 16s *cli*, ~ 9s *REPL*
- Cython:

## Run commands - run from relevant directory 
- CPython:
    - python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 
    - *python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 > cProfile.txt* 
- PyPY:
    - *PyPy installed in pypy/pypy*
    - ./pypy/pypy3.exe -m cProfile -s tottime .\sim_script_demo.py  | select -first 10 
    - *./pypy/pypy3.exe -m cProfile -s tottime .\sim_script_demo.py  | select -first 10 > cProfile.txt*
- Julia
    - julia .\sim_script_demo.py 
    - *julia .\sim_script_demo.py > time.txt*
    - **Alternatively** run script in REPL for better performance (more compiled)

## TODO
- Plot outputs, no Pickle/Pandas -> sanity check outputs


