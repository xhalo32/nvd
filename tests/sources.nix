# Tests for `nvd sources` subcommands.
#
# Uses NixOS VM tests so that the nix daemon is available for
# `nix derivation show`. Instantiates two versions of `hello` inside
# the VM to get .drv paths.
#
# Run with: nix-build tests/sources.nix
{
  pkgs ? import <nixpkgs> { },
}:

let
  nvd = import ../default.nix { inherit pkgs; };

  # Pinned nixpkgs tarballs — hello 2.12.1 and 2.12.2
  pin1 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3e2cf88148e732abc1d259286123e06a9d8c964a.tar.gz";
    sha256 = "1gvlrbl3fx1fwyb26w5k8rdlxnhzf11si7pzf3khw9n1v4jhqdw0";
  };
  pin2 = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
    sha256 = "0m0xmk8sjb5gv2pq7s8w7qxf7qggqsd3rxzv3xrqkhfimy2x7bnx";
  };
in
pkgs.testers.runNixOSTest {
  name = "nvd-sources";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [ nvd pkgs.jq ];
    nix.settings.experimental-features = [ "nix-command" ];
    virtualisation.additionalPaths = [ pin1 pin2 ];
  };

  testScript = ''
    import json

    machine.wait_for_unit("default.target")
    machine.succeed("nvd --version")

    # Instantiate hello from both pins inside the VM
    hello1 = machine.succeed(
        "nix-instantiate -E '(import ${pin1} {}).hello' 2>/dev/null"
    ).strip()
    hello2 = machine.succeed(
        "nix-instantiate -E '(import ${pin2} {}).hello' 2>/dev/null"
    ).strip()
    stdenv1 = machine.succeed(
        "nix-instantiate -E '(import ${pin1} {}).stdenv' 2>/dev/null"
    ).strip()
    stdenv2 = machine.succeed(
        "nix-instantiate -E '(import ${pin2} {}).stdenv' 2>/dev/null"
    ).strip()

    ## Test: sources list (JSON)
    with subtest("sources list JSON"):
        output = machine.succeed(
            f"nvd sources list {hello1} --exclude {stdenv1} --format json 2>/dev/null"
        )
        sources = json.loads(output)
        assert isinstance(sources, list), "Output must be a JSON array"
        assert len(sources) > 0, "Must have at least one source"

        for s in sources:
            assert "path" in s, f"Missing 'path' in {s}"
            assert "name" in s, f"Missing 'name' in {s}"
            assert "kind" in s, f"Missing 'kind' in {s}"
            assert "parent" in s, f"Missing 'parent' in {s}"

        names = [s["name"] for s in sources]
        assert "hello-2.12.1.tar.gz" in names, f"Missing hello tarball in {names}"

        kinds = set(s["kind"] for s in sources)
        assert "fod" in kinds, "No FODs found"
        assert "input_source" in kinds, "No input_sources found"

        parents = set(s["parent"] for s in sources)
        assert "hello-2.12.1" in parents, f"Missing hello-2.12.1 parent in {parents}"

    ## Test: sources list (tree)
    with subtest("sources list tree"):
        output = machine.succeed(
            f"nvd --color=never sources list {hello1} --exclude {stdenv1} 2>/dev/null"
        )
        assert "hello-2.12.1" in output, "Tree must mention hello-2.12.1"
        assert "fod" in output, "Tree must show fod entries"
        assert "input_source" in output, "Tree must show input_source entries"

    ## Test: sources diff
    with subtest("sources diff"):
        output = machine.succeed(
            f"nvd --color=never sources diff {hello1} {hello2} "
            f"--exclude {stdenv1} {stdenv2} 2>/dev/null"
        )
        assert "hello" in output, "Diff must mention hello"
        assert "curl" in output, "Diff must mention curl"
        assert "Sources:" in output, "Diff must show summary line"

    ## Test: sources collect
    with subtest("sources collect"):
        machine.succeed(
            f"nvd sources collect {hello1} --exclude {stdenv1} "
            f"--output /tmp/sources 2>/dev/null"
        )
        machine.succeed("test -d /tmp/sources/hello-2.12.1")
        machine.succeed("test -L /tmp/sources/hello-2.12.1/hello-2.12.1.tar.gz")

        target = machine.succeed(
            "readlink /tmp/sources/hello-2.12.1/hello-2.12.1.tar.gz"
        ).strip()
        assert target.startswith("/nix/store/"), f"Symlink must point to store: {target}"
  '';
}
