# 1GNT-alpha-BBN

CLASS with a rescaled gravitational constant, `G = lambda_G**2 * G_N`, and a
helium abundance taken from a BBN table computed with the same rescaling.

Upstream CLASS is **v3.2.0**, commit
`aa92943e4ab86b56970953589b4897adf2bd0f99`. `build.sh` pins both and warns if
the upstream tag has moved.

## Build and check

```bash
./build.sh                       # or ./build.sh /some/other/path
cd class_build && mkdir -p output
./class ../ini/lambda_G_1.00.ini
md5sum output/lambda_G_1.00_cl_lensed.dat   # 64ebf42b78f6054639947f0d10e2c70e
```

To run all eight reference models and check every spectrum,

```bash
for f in ../ini/lambda_G_*.ini; do ./class "$f"; done
md5sum -c ../ini/CHECKSUMS.md5
```

## The model

`lambda_G = sqrt(G/G_N)` is a single extra input parameter, read by
`input.c` and stored in the `background` structure. Wherever `G` enters a
background or thermodynamic quantity, it is replaced by `lambda_G**2 * G`.

The **physical densities are held fixed**. CLASS defines `omega_b` and
`omega_cdm` with `G = G_N` in the critical density, so holding `rho_i` fixed
means scaling the CLASS inputs,

```
h          = 0.6781    * lambda_G
omega_b    = 0.0223828 * lambda_G**2
omega_cdm  = 0.1201075 * lambda_G**2
```

The physical densities `omega_i / lambda_G**2` are therefore the same in all
our models, and those are the numbers a BBN code must be given. See
`ini/README.md` for the full convention, including the prescription that keeps
the reionization redshift fixed across models.

## Files

| Path | What it is |
|---|---|
| `class.patch` | the complete diff against upstream v3.2.0 |
| `MODIFICATIONS.md` | the files touched, one line each |
| `build.sh` | clone, patch, copy the BBN table, compile |
| `bbn/sBBN_lambda_G.dat` | the `(omega_b_phys, lambda_G) -> YHe` table |
| `bbn/README.md` | its format, and the warning about column 2 |
| `ini/lambda_G_*.ini` | the eight reference runs, as CLASS emitted them |
| `ini/CHECKSUMS.md5` | md5 of the eight lensed spectra |
| `ini/README.md` | the parameter convention and the Y_He provenance |

## Reproducibility

The patch is verified in a stronger sense than merely applying cleanly. Applied
to a bare clone of upstream v3.2.0, it reconstructs our working tree character
for character over `include/`, `main/`, `source/` and `python/cclassy.pxd`.
The `md5` checks above then confirm that the reconstructed code reproduces the
published spectra bit for bit.

## Using this model

If you use `1GNT-alpha-BBN`, please cite

- the CLASS II paper, [arXiv:1104.2933](http://arxiv.org/abs/1104.2933),
- Lamine, B., Ozdalkiran, Y., Mirouze, L., et al. 2025, A&A, 697, A109,
  for the treatment of a varying gravitational constant in CLASS,
- Lamine, B., Beauchamp, S., Blanchard, A., et al., for this model,
  reference to be completed on publication,
- and the Zenodo DOI of the release you used.
