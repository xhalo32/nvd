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
