# system-scripts
`system-scripts` provides the `system` command, which can manage a flake-based NixOS system. It can update your lockfile, rebuild your system, commit your changes (if you're using git), and more.

## installation
1. Add `system-scripts.url = "github:tom-ricci/system-scripts` to your flake's `inputs`
2. Pass `system-scripts` to your configuration
3. Append it to `environment.systemPackages`, or wherever you define your packages
4. Set the `$SYSTEM_SCRIPTS_CONFIG_ROOT` environment variable to the root directory of your flake. This would've been an option, but flakes don't support options :(

## usage
Use `system --help` for more information.

## building
See `flake.nix`.

## development
test