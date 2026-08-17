# Nabu NixOS Images

> [!NOTE]
> It is better to run `sudo nixos-rebuild boot` instead of `switch`,
> because the latter will broken some services for some reason.
> And you should also build the UKI file and copy it to ESP,
> since this make the system take effects.
>
> ```bash
> # like this
> nix build ~/NixOS#nixosConfigurations.XiaomiNabu.config.system.build.uki --impure
> sudo cp result/nixos.efi /boot/EFI/nixos
> ```
