# nvd - Nix/NixOS package version diff tool

**nvd** is a tool for diffing the versions of all store paths in the closures of
two Nix store paths, neatly summarizing the differences.  This is mainly
intended for comparing two system configurations and is inspired by the output
of `emerge -pv` from Gentoo's Portage package manager.  nvd could also be
likened to the output of Debian's `apt upgrade -V`, or any equivalent from other
distributions' package managers.  nvd isn't limited to comparing system
configurations though, and can work with any two store paths.

I wrote nvd as a way to see what is changing on my systems when I run
`nixos-rebuild`.  Package rebuilds usually aren't important to me, but I need to
know when versions change.  Usually I care most about packages that are included
in `environment.systemPackages`, so packages in this list are highlighted and
coloured specially and changes to this list are reported.

The recommended way to obtain nvd is through Nixpkgs, where it has the attribute
name `nvd`.

I recommend wrapping your usual `nixos-rebuild` call in a script that compares
the result to the current system:

    nixos-rebuild build "$@" && nvd diff /run/current-system result

Here is an example session.  We can see that Nixpkgs updates have been pulled
in, bringing in various package updates.  Firefox and cpupower have been
installed explicitly in `systemPackages`, and `bpytop` has been newly added to
the list:

    $ nvd diff /nix/var/nix/profiles/system-{14,15}-link
    <<< /nix/var/nix/profiles/system-14-link
    >>> /nix/var/nix/profiles/system-15-link
    Version changes:
    [U*]  #1  cpupower                5.4.87 -> 5.4.88
    [U*]  #2  firefox                 84.0.1 -> 84.0.2
    [U.]  #3  firefox-unwrapped       84.0.1 -> 84.0.2
    [U.]  #4  initrd-linux            5.4.87 -> 5.4.88
    [U.]  #5  linux                   5.4.87 -> 5.4.88
    [U.]  #6  nixos-system-unnamed    20.09.git.6ad5c94ed93 -> 20.09.git.9bf1626e7bb
    [U.]  #7  system76-acpi-module    1.0.1-5.4.87 -> 1.0.1-5.4.88
    [U.]  #8  system76-io-module      1.0.1-5.4.87 -> 1.0.1-5.4.88
    [U.]  #9  x86_energy_perf_policy  5.4.87 -> 5.4.88
    Added packages:
    [A+]  #1  bpytop  1.0.50
    Closure size: 2205 -> 2206 (38 paths added, 37 paths removed, delta +1).

## Derivation graph and build-time source analysis

To list and analyze sources of a package, `nvd sources list` is the right tool.
It's recommended to exclude irrelevant subgraphs, e.g. stdenv.
To do this, one needs to get the stdenv from the same nixpkgs.

    $ nvd sources list $(nix-instantiate -E '(import ./examples/hello1.nix).package') --exclude $(nix-instantiate -E '(import ./examples/hello1.nix).stdenv')
    Loading target graph: /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
      246 derivations total
    29 unique derivations after exclusion
    49 sources (9 FODs, 40 input_sources)
    
    bash-5.2p37
      input_source   separate-debug-info.sh
    
    bootstrap-stage4-gcc-wrapper-14.2.1.20250322
      input_source   role.bash
      input_source   utils.bash
    
    byacc-20241231
      fod            byacc-20241231.tgz
    
    curl-8.12.1
      fod            curl-8.12.1.tar.xz
    
    gzip-1.13
      input_source   die.sh
    
    hello-2.12.1
      fod            hello-2.12.1.tar.gz
      input_source   audit-tmpdir.sh
      input_source   builder.sh
      input_source   builder.sh.1
      input_source   compress-man-pages.sh
      input_source   default-builder.sh
      input_source   hook.sh
      input_source   make-symlinks-relative.sh
      input_source   move-docs.sh
      input_source   move-lib64.sh
      input_source   move-sbin.sh
      input_source   move-systemd-user-units.sh
      input_source   multiple-outputs.sh
      input_source   no-broken-symlinks.sh
      input_source   patch-shebangs.sh
      input_source   prune-libtool-files.sh
      input_source   reproducible-builds.sh
      input_source   set-source-date-epoch-to-latest.sh
      input_source   setup.sh
      input_source   source-stdenv.sh
      input_source   strip.sh
      input_source   write-mirror-list.sh
    ...

To analyze differences in the sources of two versions of a package, e.g. `hello:2.12.1` and `hello:2.12.2`, the `nvd sources diff` tool is provided.
Here, we exclude the stdenv graphs of both nixpkgs versions

    $ nvd sources diff $(nix-instantiate -E '(import ./examples/hello1.nix).package') $(nix-instantiate -E '(import ./examples/hello2.nix).package') --exclude $(nix-instantiate -E '(import ./examples/hello1.nix).stdenv') $(nix-instantiate -E '(import ./examples/hello2.nix).stdenv')
    Loading target graph: /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
    Loading exclude graph: /nix/store/ljjhsmahjyc0l49q4v21mkzrhn2p24ra-stdenv-linux.drv
      402 derivations total
    29 unique derivations after exclusion
    49 sources (9 FODs, 40 input_sources)
    Loading target graph: /nix/store/ljxsxdy1syy03b9kfnnh8x7zsk21fdcq-hello-2.12.2.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
    Loading exclude graph: /nix/store/ljjhsmahjyc0l49q4v21mkzrhn2p24ra-stdenv-linux.drv
      402 derivations total
    29 unique derivations after exclusion
    50 sources (9 FODs, 41 input_sources)
    <<< /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
    >>> /nix/store/ljxsxdy1syy03b9kfnnh8x7zsk21fdcq-hello-2.12.2.drv
    
    Version changes:
    [U]  #1  curl   8.12.1 -> 8.13.0
    [U]  #2  gzip   1.13 -> 1.14
    [U]  #3  hello  2.12.1 -> 2.12.2
      curl:
        + 0001-http2-fix-stream-window-size-after-unpausing.patch
        - curl-8.12.1.tar.xz
        + curl-8.13.0.tar.xz
      hello:
        ~ builder.sh
        ~ builder.sh.1
        - hello-2.12.1.tar.gz
        + hello-2.12.2.tar.gz
    
    Added packages:
    [A]  #1  gcc-wrapper  14.2.1.20250322
    
    Removed packages:
    [R]  #1  bootstrap-stage4-gcc-wrapper  14.2.1.20250322
    
    Sources: 49 -> 50.

To examine all sources closely, one can use `nvd sources collect` to create a directory structure that contains sources of the package as symbolic links to the nix store

    nvd sources collect $(nix-instantiate -E '(import ./examples/hello1.nix).package') --exclude $(nix-instantiate -E '(import ./examples/hello1.nix).stdenv') -o hello1sources
    Loading target graph: /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
      246 derivations total
    29 unique derivations after exclusion
    49 sources (9 FODs, 40 input_sources)

Note that currently non-file-like sources like environment variables that are part of a derivation are not collect nor detected by the list/diff tools.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
