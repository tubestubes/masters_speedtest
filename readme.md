# Experimenting with / learning different ways to speed up my Master's python simulation

## Methods
- Caching: *Effective caching Road.tt()*
- PyPy: *Great cProfile performace, no Pandas support for data export*
- Numba: *Unsuccessful: uses custom classes in tt()* 
- Julia: *Work-In-Progress*
- Cython: *TODO*

## Run commands
- CPython:
    python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 
    *python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 > cProfile.md* 

- PyPY
    *PyPy installed in pypy/pypy*
    ./pypy/pypy3.exe -m cProfile -s tottime .\sim_script_demo.py  | select -first 10 
     *./pypy/pypy3.exe -m cProfile -s tottime .\sim_script_demo.py  | select -first 10 > cProfile.md*

## Timings
- Base *original code*: ~ 60s
- Caching: ~ 30s
- PyPy: ~ 11s *no data record*
- Numba: ~ 90s - *cannot jit tt()*
- Juila:
- Cython:

## TODO
- Plot outputs, no Pickle -> sanity check outputs


