# Experimenting with / learning different ways to speed up my Master's python simulation

## Methods
- Caching: *Effective, caching Road.tt()*
- PyPy: *Better cProfile performace, no Pandas support*
- Numba: *Unsuccessful: uses custom classes* 
- Julia: *Work-In-Progress*
- Cython: *TODO*

## Run command

python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 

*python -m cProfile -s tottime .\sim_script_demo.py | select -first 10 > cProfile.md* to save


## TODO
- Plot outputs, no Pickle -> sanity check outputs

