# What this patch changes

`class.patch` is the complete diff against CLASS v3.2.0, commit
`aa92943e4ab86b56970953589b4897adf2bd0f99`. It is 657 lines over 11 files.

Applied to a bare clone of that commit it reconstructs our working tree
character for character over `include/`, `main/`, `source/` and
`python/cclassy.pxd`, and the resulting code reproduces the published spectra
bit for bit, see `ini/CHECKSUMS.md5`.

## The single idea

`lambda_G = sqrt(G/G_N)` is one new input parameter. Everywhere the laboratory
`G` enters a background or thermodynamic quantity, `_G_` is replaced by
`pow(pba->lambda_G,2)*_G_`. That accounts for nine of the eleven files. The
tenth, `source/thermodynamics.c`, also carries the rewritten BBN reader, and
the eleventh is the Cython wrapper.

Nothing is changed in the Boltzmann hierarchy, the transfer functions, the
lensing module or the output module.

## File by file

| File | Lines | What |
|---|---|---|
| `include/background.h` | +3 | `lambda_G` in the `background` structure, its index `index_bg_lambda_G` in the background vector, and a `lambda_G` output argument added to `background_varconst_of_z()` |
| `include/precisions.h` | +1 -1 | default `sBBN_file` now points to `/external/bbn/sBBN_lambda_G.dat` |
| `include/primordial.h` | +3 | `primordial_init()` takes the `background` structure, so that the primordial module can reach `lambda_G` |
| `main/class.c` | +1 -1 | the matching `primordial_init()` call |
| `python/cclassy.pxd` | +2 -1 | `double lambda_G` in the declared `background` structure, and the new `primordial_init()` signature. Without it the Python wrapper does not build |
| `source/background.c` | +9 -2 | `index_bg_lambda_G` declared under `has_varconst`, `background_varconst_of_z()` returns `lambda_G` on both sides of the transition redshift, the value is stored in the background output, and `factor_ncdm` and `rho_nu_rel` use the rescaled `G` |
| `source/fourier.c` | +2 -1 | `rho_crit_today_in_msun_mpc3` uses the rescaled `G`. See the note below |
| `source/input.c` | +8 -6 | reads `lambda_G`, defaults it to 1, and uses the rescaled `G` in the four conversions between `Omega0_g` and `T_cmb` |
| `source/perturbations.c` | +1 -1 | `Nnow`, the present hydrogen number density, uses the rescaled `G` |
| `source/primordial.c` | +7 -4 | `rho_end` and `Omega_g0` in the inflation module use the rescaled `G` |
| `source/thermodynamics.c` | +65 -62 | the BBN reader, plus the rescaled `G` in `n_e`, in `SIunit_nH0`, in the dark-matter/photon coupling terms, and the updated calls to `background_varconst_of_z()` |

## The BBN reader

`thermodynamics_helium_from_bbn()` is rewritten rather than reinterpreted. In
unmodified CLASS the table axes are `(omega_b, Delta N_eff)`. Here the second
axis is `lambda_G`, and the variables and error messages follow,
`num_lambda_G`, `YHe_at_lambda_G`, `ddYHe_at_lambda_G`. A user who supplies a
table in the wrong format gets a message that names `lambda_G`.

Two points worth knowing.

The lookup divides by `lambda_G**2` before entering the table,

```c
omega_b = pba->Omega0_b*pba->h*pba->h/pba->lambda_G/pba->lambda_G;
```

because the tabulated first column is the physical baryon density, the one a
BBN code must be given. See `bbn/README.md`.

Two `class_test_except()` guards stop the run, rather than extrapolating, when
`lambda_G` falls outside the tabulated range, and the message says what to do,
fix `YHe` to a number instead of `BBN`. That is exactly what the reference
input files in `ini/` do.

## Note on `source/fourier.c`

`rho_crit_today_in_msun_mpc3` converts to solar masses per cubic megaparsec
and is used by the non-linear module. Rescaling `G` there is consistent with
the rest of the patch, but it has no effect on any result published with this
code, because the non-linear module is not used: the reference runs request
no non-linear spectra, and CLASS reports `Nonlinear calculations skipped`.
Anyone combining this patch with HMcode or Halofit should look at that line
first.
