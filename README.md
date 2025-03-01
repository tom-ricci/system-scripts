# system-scripts
`system-scripts` provides the `system` command, which can manage a flake-based NixOS system. It can update your lockfile, rebuild your system, commit your changes (if you're using git), and more.

## installation
1. Pass `github:tom-ricci/system-scripts` to your configuration:
```nix
{
    ...
    inputs.system-scripts.url = "github:tom-ricci/system-scripts";
    ...
    outputs = { self, system-scripts, ...}: (
        ...
    );
    ...
}
```
2. Append it to `environment.systemPackages`:
```nix
{ pkgs, inputs, ... }: {
    ...
    environment.systemPackages = with pkgs; [
        ...
        inputs.system-scripts."${pkgs.system}".packages.system-scripts
    ];
    ...
}
```
3. Set the `$SYSTEM_SCRIPTS_CONFIG_ROOT` environment variable to the location of your flake. This would've been an option, but flakes don't support options ☹️

## usage
Use `system --help` for more information.

## building
See `flake.nix`.

## development
The `main` branch is stable. All development happens on `dev`; you can switch to it with `inputs.system-scripts.url = "github:tom-ricci/system-scripts/dev"`