# shellcheck disable=SC2154

# WARNING: this script should be run by nix shells

set -euo pipefail

export PATH="$binPath:$PATH"
export HOME="$TMPDIR"
export NIX_STATE_DIR="$TMPDIR/state"

diskSize="20G"
diskImage="$TMPDIR/rootfs.img"
mountPoint="$TMPDIR/mnt"

sudo rm -rf "$out"
mkdir -p "$out" "$mountPoint"
chmod 755 "$TMPDIR"

echo "::group::set up rootfs.img"
truncate -s "$diskSize" "$diskImage"
mkfs.ext4 "$diskImage"
sudo mount -o loop "$diskImage" "$mountPoint"
echo "::endgroup::"

echo "::group::run nixos-install"
nix-store --load-db <"$closureInfo/registration"
sudo env "PATH=$PATH" nixos-install \
  --channel "$channelSources" \
  --max-jobs 8 \
  --no-bootloader \
  --no-root-passwd \
  --root "$mountPoint" \
  --system "$configBuild"
echo "::endgroup::"

echo "::group::run nixos-enter"
# important, to generate files with the closure
sudo env "PATH=$PATH" nixos-enter \
  --root "$mountPoint" \
  -- /nix/var/nix/profiles/system/bin/switch-to-configuration boot
echo "::endgroup::"

echo "::group::move the image"
sudo umount -R "$mountPoint"
e2fsck -f -y "$diskImage"
resize2fs -M "$diskImage"
mv "$diskImage" "$out"
echo "::endgroup::"
