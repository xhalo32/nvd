# nvd changelog

## 0.1.0

- Optimized first level dependency calculation to read depenencies from
  `nix-store` rather than walking a directory tree manually (issue #4).  This
  also fixes nvd's support for things other than simple `buildEnv`s, e.g. file
  entries at the top level of the store, derivations, and references in files
  other than symlinks.

## 0.0.1

Initial release.
