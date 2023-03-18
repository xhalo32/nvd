# nvd changelog

## 0.2.1 (2023-03-17)

- Fixed reference to undefined variable in `StorePath` constructor (issue #12),
  plus some code lint.

## 0.2.0 (2022-10-15)

- Add display of the change in closure disk size (issue #8).

- Add a `--nix-bin-dir` option for allowing easier control over which Nix
  binaries are used (issue #9).

## 0.1.2 (2021-11-05)

- Added a flake.nix, thanks @dadada_.

- Fixes to example commands in the readme.

## 0.1.1 (2021-05-16)

- Fix handling of SIGPIPE to exit cleanly.

## 0.1.0 (2021-05-16)

- Add a mandatory action argument to the CLI.  The existing diff functionality
  is under the `diff` command.  A new `list` command is now implemented as well
  (issue #5).

- Optimized first level dependency calculation to read depenencies from
  `nix-store` rather than walking a directory tree manually (issue #4).  This
  also fixes nvd's support for things other than simple `buildEnv`s, e.g. file
  entries at the top level of the store, derivations, and references in files
  other than symlinks.

## 0.0.1

Initial release.
