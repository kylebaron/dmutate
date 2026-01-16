# 0.2.0

- Removed underscore variants of dplyr verbs (#6). 

- Documentation cleanup and modernization (#7).

# 0.1.1.9000

- Fixed a bug with rmvnorm and rlmvnorm where an incorrect number of variates were 
simulated when all boundaries were `-Inf` to `Inf

- Import from MASS; add `rmassnorm` and `rlmassnorm` to simulate multivariate
normal from the MASS function

- Added several tests
