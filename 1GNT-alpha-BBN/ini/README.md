# Reference input files, 1GNT-alpha-BBN

The ten `.ini` files here are the exact inputs of the reference runs of
Lamine et al. Each one was emitted by CLASS itself as `<root>parameters.ini`
at the end of the corresponding run, so it lists every parameter actually
read, with every other one left at its CLASS default. Only the `root` line
was edited, to give the outputs readable names, and `overwrite_root` was set
to `yes` where it was not already.

With the CLASS default `overwrite_root = no`, a two-digit index is appended to
the root, which is where the names of the original run files come from: a root
of `output/explanatory_1` produced `explanatory_100_cl_lensed.dat`. There was
never a model numbered 100.

Run one with

```
./class ini/lambda_G_1.00.ini
```

## Parameter convention

The model is defined by `lambda_G = sqrt(G/G_N)`, with the **physical
densities held fixed**. The CLASS inputs `omega_b` and `omega_cdm` are defined
with `G = G_N` in the critical density, so holding `rho_i` fixed means scaling
them,

```
h          = 0.6781    * lambda_G
omega_b    = 0.0223828 * lambda_G^2
omega_cdm  = 0.1201075 * lambda_G^2
```

These hold exactly, to every digit, in all ten files. The physical densities
are therefore the same throughout, `omega_b/lambda_G^2 = 0.0223828` and
`omega_cdm/lambda_G^2 = 0.1201075`. Those are the numbers to feed to a BBN
code, not the CLASS inputs.

`tau_reio` is set so that the reionization redshift is the same in every
model. With `n_e` proportional to `(1-Y_He)` times an invariant `rho_b`, and
`dt` proportional to `1/H` hence to `1/lambda_G`,

```
tau_reio(lambda_G) = 0.054308 * (1/lambda_G) * (1-Y_He) / (1-0.246949)
```

which reproduces the value in every file.

All other parameters are common to the ten runs, in particular
`A_s = 2.100549e-09`, `n_s = 0.9660499`, `T_cmb = 2.7255`, `N_ur = 3.044`,
`recombination = HyRec`, `varying_fundamental_constants = instantaneous` with
`varying_transition_redshift = 50.`, and `l_max_scalars = 3000`.

## Two prescriptions for Y_He, and which file uses which

**Eight of the ten pin `YHe` to an explicit number**, obtained from a direct
run of the modified PArthENoPE at that `lambda_G`. CLASS consults
`../bbn/sBBN_lambda_G.dat` only when the input is `YHe = BBN`, so these eight
runs do not touch the table, and reproducing them does not depend on it.

**The two models of the triplet, `lambda_G` = 0.9 and 1.1, carry
`YHe = BBN`** and do read the table. They were run later than the other
eight, to form with `lambda_G = 1.0` the triplet from which the local
logarithmic derivatives of the paper are obtained. Both lie comfortably inside
the tabulated range.

The two prescriptions differ by at most 1.5e-4 in relative terms on `Y_He`,
measured directly, which propagates to less than 1.5e-4 on any of the
exponents quoted in the paper.

This also means the table only limits the exploration of other values of
`lambda_G`. It covers `lambda_G` in [0.70, 1.30], and the code stops with an
error outside that interval rather than extrapolating. See `../bbn/README.md`.

| lambda_G | h | omega_b | omega_cdm | Y_He | tau_reio |
|---|---|---|---|---|---|
| 0.25 | 0.169525 | 0.001398925 | 0.00750671875 | 0.0477548 | 0.274693386353 |
| 0.50 | 0.33905 | 0.0055957 | 0.030026875 | 0.132015 | 0.125193458026 |
| 0.75 | 0.508575 | 0.012590325 | 0.06756046875 | 0.197054 | 0.077208389813 |
| 0.90 | 0.61029 | 0.018130068 | 0.097287075 | `BBN` | 0.0618249508 |
| 1.00 | 0.6781 | 0.0223828 | 0.1201075 | 0.246949 | 0.054308 |
| 1.10 | 0.74591 | 0.027083188 | 0.145330075 | `BBN` | 0.0482644963 |
| 1.25 | 0.847625 | 0.034973125 | 0.18766796875 | 0.286569 | 0.041160570265 |
| 1.50 | 1.01715 | 0.0503613 | 0.270241875 | 0.31902 | 0.032740289693 |
| 1.75 | 1.186675 | 0.068547325 | 0.36782921875 | 0.346253 | 0.026940836734 |
| 2.00 | 1.3562 | 0.0895312 | 0.48043 | 0.369562 | 0.022732741145 |

## Non-regression check

`CHECKSUMS.md5` holds the md5 of the lensed CMB spectra of the reference runs.
After building the code with `build.sh`, run the files and check that you
recover them,

```
for f in ini/lambda_G_*.ini; do ./class "$f"; done
md5sum -c ini/CHECKSUMS.md5
```

The checksums are of file contents, so they are insensitive to `root`. They do
depend on the compiler and on the CLASS precision settings, so a mismatch is a
reason to look, not necessarily a reason to worry. A difference in the last
digits of a few multipoles will break an md5 while being physically
irrelevant. If a checksum fails, compare the spectra numerically before
concluding anything.
