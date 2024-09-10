# nvd changelog

## 0.2.4 (unreleased)

- Added `--sort` option for controlling the order packages are listed in, for
  issue #17.

- In the "Version changes" section of a diff, highlight the portions of version
  numbers that have changed, i.e., everything after the part common to all
  versions (issue #17).  This makes it easier to spot whether packages have had
  major or minor version bumps.

- Respect the `NO_COLOR` environment variable and disable colour when it is set
  and nonempty (when the default `--color=auto` is used).  For more info see:
  https://no-color.org

## 0.2.3 (2023-05-22)

- Fix compatibility with nix-2.3 where `nix --extra-experimental-features` isn't
  a known flag yet.  We have to switch on the version of Nix we've been given.

- Stricter behaviour around invoking `nix`.  Nix returning a nonzero exit code
  will cause nvd to abort in most cases.

## 0.2.2 (2023-05-22)

- Fixed crash when `nix-store --query --references` returns nothing (e.g. for a
  Nix package with no dependencies), which causes the assertion from issue #12
  to fail.

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
