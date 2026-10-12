# BBN table for the 1GNT-alpha model

`sBBN_lambda_G.dat` replaces the standard CLASS BBN table. It is read by
`thermodynamics_helium_from_bbn()` in `source/thermodynamics.c` and selected
with `sBBN_file`.

## Format

The layout is the standard CLASS one.

- Blank lines and lines starting with `#` are ignored.
- The first data line holds two integers, the number of values of the first
  and of the second grid variable.
- Every later data line holds three numbers.
- The first grid variable runs fastest, so the file is a sequence of blocks
  of constant second variable, each block listing all values of the first.

## Column 1, the physical baryon density

Column 1 is the **physical** baryon density
`omega_b_phys = omega_b / lambda_G**2`, the one that corresponds to a fixed
`rho_b`. This is what a BBN code must be given, since it computes its critical
density with the laboratory value of `G`. In the model family used in our
papers `omega_b_phys = 0.0223828` for every value of `lambda_G`, so all our
runs sit at the same point on this axis.

The header line of the data file words this the other way round, as a warning
that `omega_b` there is not the CLASS input. Both statements say the same
thing. The quantity tabulated is the physical density.

## Column 2 is lambda_G, not Delta N_eff

In unmodified CLASS the three columns are `(omega_b, DeltaN, YHe)` with
`DeltaN = N_eff - 3.046`, computed by CLASS itself from the background.

**Here the second column is `lambda_G = sqrt(G/G_N)`.** The reader in
`thermodynamics.c` was rewritten accordingly, so the variable names
(`num_lambda_G`, `YHe_at_lambda_G`, `ddYHe_at_lambda_G`) and the error
messages refer to `lambda_G` throughout. Feeding this file to unmodified
CLASS, or an unmodified table to this code, is a silent physics error in one
direction and a clear error message in the other.

## Grid

| Column | Quantity | Values | Range |
|---|---|---|---|
| 1 | `omega_b_phys` | 51 | 0.01278 to 0.03106 |
| 2 | `lambda_G` | 33 | 0.70 to 1.30 |
| 3 | `YHe` | 51 x 33 = 1683 | |

## Provenance, and the range limit

Computed with a modified version of PArthENoPE in which the gravitational
constant is rescaled by `lambda_G**2`, fed with the physical densities.

**The grid covers `lambda_G` from 0.70 to 1.30 only.** Outside that range
CLASS stops with an error rather than extrapolating, and there is no way
around it with the files provided here. A value of `lambda_G` outside the grid
requires a fresh run of the modified PArthENoPE, whose source we do not
redistribute. Please contact us, and we will put you in touch with its
authors.

**Reproducing our published runs does not require this table.** Every
reference input file in `../ini/` sets `YHe` to an explicit number, obtained
from a direct run of the modified PArthENoPE at that `lambda_G`. CLASS reads
the table only when the input is `YHe = BBN`. The table is therefore a
convenience for exploring other values of `lambda_G`, not a dependency of our
results.
