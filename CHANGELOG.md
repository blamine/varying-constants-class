# Changelog

## v1.0.1 (1GNT-alpha-BBN)

The patch is rebuilt from the working tree used for our MCMC chains, which had
received corrections after v1.0.0 was assembled. See
`1GNT-alpha-BBN/MODIFICATIONS.md`, section "Changes in v1.0.1", for details.

- HyRec-2: the baryon density entering the SWIFT recombination correction is
  now the physical one. This changes the outputs for `lambda_G != 1`, by an
  amount that grows with `|lambda_G - 1|` (`theta_s` by `-2e-4` at
  `lambda_G = 1.1` and `-4e-3` at 2, lensed CMB spectra by up to 0.6% and
  11%). Results at `lambda_G = 1` are unchanged.
- Physical photon density in the Compton coupling rate between photons and
  baryons. This changes the baryon temperature and the residual ionization in
  the dark ages for `lambda_G != 1` (`T_b/T_gamma` at `z = 200` now runs from
  0.84 to 0.86 for `lambda_G` from 0.25 to 2, against 0.49 to 0.95 in v1.0.0),
  with a small effect on the CMB spectra (below `1e-3` on TT at `ell > 30`
  for `lambda_G >= 0.9`).
- Physical densities in the exotic energy-injection and non-injection heating
  terms and in the spectral distortions module. No effect on the reference
  runs.
- An explicit error when primordial black hole evaporation or accretion is
  requested with `lambda_G != 1`, since these channels have not been adapted.
- The `lambda_G` column of the background output now has its title.
- The Python wrapper builds again (`classy.pyx` follows the new
  `primordial_init()` signature), and exposes `lambda_G`.
- The `root` of the ten reference `.ini` files no longer ends with `_`. CLASS
  appends one itself, so the outputs were named `lambda_G_<l>__cl_lensed.dat`
  and did not match the names listed in `ini/CHECKSUMS.md5` and in the README.
- README: the paper of this model is submitted to PRD, the table gives the
  Zenodo concept DOI, and the announcement of a separate dataset, which was
  never created, is replaced by how to regenerate and check the outputs.
- `ini/CHECKSUMS.md5` regenerated with v1.0.1. The checksums differ from those
  of v1.0.0 for every `lambda_G != 1`.

## v1.0.0

First public release, 1GNT-alpha-BBN.
