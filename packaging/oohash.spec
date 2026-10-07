Name:           oohash
Version:        0.1.0
Release:        1%{?dist}
Summary:        Calculates BLAKE3, SHA-256, and SHA3-512 hashes simultaneously in a single pass.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oohash
Source0:        oohash-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oohash is a sovereign, capability-bounded MULTI HASH written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oohash
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oohash-uninstall

%files
/usr/bin/oohash
/usr/bin/oohash-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
