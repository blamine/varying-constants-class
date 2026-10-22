# What this patch changes

`class.patch` is the complete diff against CLASS v3.2.0, commit
`aa92943e4ab86b56970953589b4897adf2bd0f99`. In v1.0.1 it is 814 lines over
16 files.

Applied to a bare clone of that commit, it reconstructs our current working
tree, the one used for our MCMC chains, up to comments and whitespace, and the
resulting code reproduces the outputs of that tree bit for bit. The reference
spectra of `ini/` are checked with `ini/CHECKSUMS.md5`.

## The single idea

`lambda_G = sqrt(G/G_N)` is one new input parameter. Everywhere the laboratory
`G` enters a background or thermodynamic quantity, `_G_` is replaced by
`pow(pba->lambda_G,2)*_G_`.

The converse matters as much. CLASS stores densities as `8 pi G rho / 3`, and
several modules turn them back into physical densities (in J/m^3, or as a
number of hydrogen atoms) with constants built on `G_N`. With a rescaled `G`,
those conversions must divide by `lambda_G**2`, otherwise they return
`lambda_G**2` times the physical density. Version 1.0.1 applies this
everywhere, see "Changes in v1.0.1" below.

`source/thermodynamics.c` also carries the rewritten BBN reader, and the
Cython wrapper is updated for the new `primordial_init()` signature.

Nothing is changed in the Boltzmann hierarchy, the transfer functions, the
lensing module or the output module.

## File by file

| File | Lines | What |
|---|---|---|
| `include/background.h` | +3 | `lambda_G` in the `background` structure, its index `index_bg_lambda_G` in the background vector, and a `lambda_G` output argument added to `background_varconst_of_z()` |
| `include/precisions.h` | +1 -1 | default `sBBN_file` now points to `/external/bbn/sBBN_lambda_G.dat` |
| `include/primordial.h` | +3 | `primordial_init()` takes the `background` structure, so that the primordial module can reach `lambda_G` |
| `main/class.c` | +1 -1 | the matching `primordial_init()` call |
| `python/cclassy.pxd` | +2 -1 | `double lambda_G` in the declared `background` structure, and the new `primordial_init()` signature |
| `python/classy.pyx` | +6 -1 | the matching `primordial_init()` call, and access to `lambda_G` from Python (`lambda_G()` and `get_current_derived_parameters(['lambda_G'])`). Without it the wrapper does not build |
| `source/background.c` | +11 -2 | `index_bg_lambda_G` declared under `has_varconst`, `background_varconst_of_z()` returns `lambda_G` on both sides of the transition redshift, the value is stored in the background output with its column title, and `factor_ncdm` and `rho_nu_rel` use the rescaled `G` |
| `source/distortions.c` | +1 -1 | the photon density converted to J/m^3 is the physical one |
| `source/fourier.c` | +3 -1 | `rho_crit_today_in_msun_mpc3` uses the rescaled `G`. See the note below |
| `source/input.c` | +8 -6 | reads `lambda_G`, defaults it to 1, and uses the rescaled `G` in the four conversions between `Omega0_g` and `T_cmb` |
| `source/perturbations.c` | +1 -1 | `Nnow`, the present hydrogen number density, uses the rescaled `G` |
| `source/primordial.c` | +7 -5 | `rho_end` and `Omega_g0` in the inflation module use the rescaled `G` |
| `source/thermodynamics.c` | +71 -66 | the BBN reader, the rescaled `G` in `n_e`, in `SIunit_nH0` and in the dark-matter/photon coupling terms, the physical photon density in the photon-baryon heating rate, and the updated calls to `background_varconst_of_z()` |
| `external/HyRec2020/wrap_hyrec.c` | +3 -1 | the baryon density passed to HyRec is the physical one, see below |
| `external/heating/injection.c` | +14 -4 | physical densities in the energy-injection module, and an explicit error for primordial black holes when `lambda_G != 1` |
| `external/heating/noninjection.c` | +3 -2 | physical densities in the non-injected heating terms |

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
fix `YHe` to a number instead of `BBN`. That is exactly what most of the
reference input files in `ini/` do.

## HyRec and the SWIFT correction

HyRec-2 computes recombination in its default `SWIFT` mode, an effective
multi-level atom corrected by a fitting function of the departure of the
cosmology from a fiducial one, through `obh2*(1-YHe)`, `ocbh2` and `Neff`. The
first combination stands for the hydrogen number density and must be the
physical baryon density, hence

```c
phy->data->cosmo->obh2 = pba->Omega0_b*pba->h*pba->h/pba->lambda_G/pba->lambda_G;
```

The second one stands for the expansion rate in the matter era, `H^2`
proportional to `G rho_cb`, and keeps the rescaled `G`.

The correction is a linear expansion around the fiducial cosmology. For
`lambda_G` far from 1, `ocbh2` lies far from its fiducial value (by a factor
`lambda_G**2`) and the correction is extrapolated. For `lambda_G` between 0.9
and 1.1 the correction to the damping wavenumber stays within
`(5.0-5.5)e-3` of the uncorrected (`EMLA2s2p`) result, as at `lambda_G = 1`,
but at `lambda_G = 0.25` or 2 the difference between corrected and
uncorrected results reaches the percent level on `k_d`. Results at large
`|lambda_G - 1|` therefore carry a modelling uncertainty of that order from
recombination alone. HyRec-2 in `FULL` mode, which would remove it, is not
available through the CLASS interface.

## Note on `source/fourier.c`

`rho_crit_today_in_msun_mpc3` converts to solar masses per cubic megaparsec
and is used by the non-linear module. Rescaling `G` there is consistent with
the rest of the patch, but it has no effect on the reference runs, because the
non-linear module is not used: they request no non-linear spectra, and CLASS
reports `Nonlinear calculations skipped`. Anyone combining this patch with
HMcode or Halofit should look at that line first.

## Changes in v1.0.1

Version 1.0.0 was built from an earlier state of our working tree. The code
used for the production runs had since received the following corrections,
which v1.0.1 now contains.

- `external/HyRec2020/wrap_hyrec.c`: physical baryon density in the SWIFT
  correction. **This is the change that matters for the CMB spectra.**
  Nothing changes at `lambda_G = 1`. Elsewhere the effect grows with
  `|lambda_G - 1|`: for the reference runs, the sound-horizon angle `theta_s`
  changes by about `-2e-4` at `lambda_G = 1.1`, `-1.5e-3` at 1.5 and
  `-4e-3` at 2, the damping wavenumber `k_d` by `+1e-3`, `+7e-3` and
  `+1.9e-2`, and the lensed CMB spectra at `ell > 30` by up to 0.6%, 4% and
  11%. The local logarithmic slopes around `lambda_G = 1` change by about
  `-0.002` for `theta_s` and `+0.009` for `k_d`.
- `source/thermodynamics.c`: physical photon density in the Compton
  coupling rate between photons and baryons (`rate_gamma_b`). In v1.0.0 the
  photon energy density entering this rate carried a spurious `lambda_G^2`,
  so that the gas stayed thermally coupled to the CMB for too long when
  `lambda_G > 1` and decoupled too early when `lambda_G < 1`. The effect is
  confined to the dark ages, where it is large: the ratio `T_b/T_gamma` at
  `z = 200` ran from 0.49 at `lambda_G = 0.25` to 0.95 at `lambda_G = 2` in
  v1.0.0, and runs from 0.84 to 0.86 in v1.0.1, which in turn changes the
  residual ionization through the temperature dependence of the
  recombination coefficient. Nothing changes at `lambda_G = 1`. The effect on
  `theta_s` and `k_d` is below `1e-5`. On the CMB spectra at `ell > 30` it
  stays below `1e-3` for TT and `2e-3` for EE when `0.9 <= lambda_G <= 2`,
  and reaches `3e-3` (TT) and `2e-2` (EE) at `lambda_G = 0.25`.
- `external/heating/injection.c`, `noninjection.c` and `source/distortions.c`:
  physical densities. Effect only with exotic energy injection or spectral
  distortions, neither of which is used in the reference runs.
- `source/background.c`: column title of `lambda_G` in the background output.
  In v1.0.0 the value was written without a title, so that the labels of the
  last columns of `*_background.dat` were shifted when the varying-constants
  module was on.
- `python/classy.pyx`: new `primordial_init()` call. In v1.0.0 the Python
  wrapper did not build ("Call with wrong number of arguments").

The checksums of `ini/CHECKSUMS.md5` are those of v1.0.1. They differ from
those of v1.0.0 for every `lambda_G != 1`.
