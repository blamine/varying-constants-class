# Modified CLASS codes for varying fundamental constants

Modified versions of [CLASS](https://github.com/lesgourg/class_public) used in
our work on cosmologies with varying fundamental constants.

This repository holds no copy of CLASS. Each model directory holds a patch
against a pinned upstream release, our own input files and tables, and a
`build.sh` that clones CLASS, applies the patch and compiles.

| Model | Upstream CLASS | What is modified | Paper | DOI |
|---|---|---|---|---|
| [`1GNT-alpha-BBN`](1GNT-alpha-BBN/) | v3.2.0 | Newton constant rescaled by `lambda_G**2`, with `YHe = BBN` reading a `(omega_b, lambda_G)` table from a modified PArthENoPE | Lamine et al., submitted to PRD | 10.5281/zenodo.23399409 |
| `2Gfix` | | | | |

## Quick start

```bash
cd 1GNT-alpha-BBN
./build.sh                       # clones CLASS, applies the patch, compiles
cd class_build && mkdir -p output
./class ../ini/lambda_G_1.00.ini
md5sum output/lambda_G_1.00_cl_lensed.dat
```

The last command should print `64ebf42b78f6054639947f0d10e2c70e`. The ten
reference models and their checksums are in `1GNT-alpha-BBN/ini/`, see
`ini/README.md` there.

## What was changed

Each model directory holds `class.patch`, the complete diff against the stated
upstream release, and `MODIFICATIONS.md`, the list of files touched with one
line each. The patch is kept minimal on purpose, it covers `include/`,
`main/`, `source/` and the Cython wrapper and nothing else.

The BBN table is kept outside the patch and documented in `bbn/README.md`.
Note in particular that its second column is `lambda_G` and not the
`Delta N_eff` that unmodified CLASS expects there.

## Using the code

You can use these modified codes freely, provided that in your publications
you cite at least

- the CLASS II paper, [arXiv:1104.2933](http://arxiv.org/abs/1104.2933),
  as requested by the CLASS authors, and
- Lamine, B., Ozdalkiran, Y., Mirouze, L., et al. 2025, A&A, 697, A109,
  for the treatment of a varying gravitational constant in CLASS.

Please also cite the paper listed for the particular model you used, and the
Zenodo DOI of the release you used.

Most of what you obtain after running `build.sh` is CLASS itself, the work of
J. Lesgourgues, T. Tram, N. Schoeneberg and contributors, used under the terms
of its own README. We make no licensing claim over it.

## The modified PArthENoPE

The BBN table was produced with a modified version of PArthENoPE in which the
gravitational constant is rescaled. That code was provided to us by its
developers and is not redistributed here. Please get in touch if you need it.

## Data

The outputs of the reference runs can be regenerated from the input files of
each model directory, and checked against the checksums provided there (see
`1GNT-alpha-BBN/ini/README.md`).
