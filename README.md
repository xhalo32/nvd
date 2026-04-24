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
    19 sources (9 FODs, 10 input_sources)
    
    byacc-20241231
      fod            byacc-20241231.tgz
    
    curl-8.12.1
      fod            curl-8.12.1.tar.xz
    
    hello-2.12.1
      fod            hello-2.12.1.tar.gz
      input_source   builder.sh
      input_source   hook.sh
      input_source   write-mirror-list.sh
    
    keyutils-1.6.3
      fod            keyutils-1.6.3.tar.gz
      fod            raw
      input_source   0001-Remove-unused-function-after_eq.patch
      input_source   conf-symlink.patch
      input_source   pkg-config-static.patch
    
    krb5-1.21.3
      fod            krb5-1.21.3.tar.gz
    
    libssh2-1.11.1
      fod            libssh2-1.11.1.tar.gz
    
    nghttp2-1.65.0
      fod            nghttp2-1.65.0.tar.bz2
    
    openssl-3.4.1
      fod            openssl-3.4.1.tar.gz
      input_source   make-binary-wrapper.sh
      input_source   nix-ssl-cert-file.patch
      input_source   openssl-disable-kernel-detection.patch
      input_source   use-etc-ssl-certs.patch

To analyze differences in the sources of two versions of a package, e.g. `hello:2.12.1` and `hello:2.12.2`, the `nvd sources diff` tool is provided.
Here, we exclude the stdenv graphs of both nixpkgs versions

    $ nvd sources diff $(nix-instantiate -E '(import ./examples/hello1.nix).package') $(nix-instantiate -E '(import ./examples/hello2.nix).package') --exclude $(nix-instantiate -E '(import ./examples/hello1.nix).stdenv') $(nix-instantiate -E '(import ./examples/hello2.nix).stdenv')
    Loading target graph: /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
    Loading exclude graph: /nix/store/ljjhsmahjyc0l49q4v21mkzrhn2p24ra-stdenv-linux.drv
      402 derivations total
    29 unique derivations after exclusion
    19 sources (9 FODs, 10 input_sources)
    Loading target graph: /nix/store/ljxsxdy1syy03b9kfnnh8x7zsk21fdcq-hello-2.12.2.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
    Loading exclude graph: /nix/store/ljjhsmahjyc0l49q4v21mkzrhn2p24ra-stdenv-linux.drv
      402 derivations total
    29 unique derivations after exclusion
    20 sources (9 FODs, 11 input_sources)
    <<< /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
    >>> /nix/store/ljxsxdy1syy03b9kfnnh8x7zsk21fdcq-hello-2.12.2.drv

    Version changes:
    [U]  #1  curl   8.12.1 -> 8.13.0
    [U]  #2  hello  2.12.1 -> 2.12.2
      curl:
        + 0001-http2-fix-stream-window-size-after-unpausing.patch
        - curl-8.12.1.tar.xz
        + curl-8.13.0.tar.xz
      hello:
        - hello-2.12.1.tar.gz
        + hello-2.12.2.tar.gz

    Sources: 19 -> 20.

To examine all sources closely, one can use `nvd sources collect` to create a directory structure that contains sources of the package as symbolic links to the nix store

    nvd sources collect $(nix-instantiate -E '(import ./examples/hello1.nix).package') --exclude $(nix-instantiate -E '(import ./examples/hello1.nix).stdenv') -o hello1sources
    Loading target graph: /nix/store/iqbwkm8mjjjlmw6x6ry9rhzin2cp9372-hello-2.12.1.drv
      275 derivations
    Loading exclude graph: /nix/store/y4zk72najykpa9lbjjj7gcvqxwncq8xb-stdenv-linux.drv
      246 derivations total
    29 unique derivations after exclusion
    19 sources (9 FODs, 10 input_sources)

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
