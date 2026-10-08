# oohash: Sovereign Multi-Algorithm Cryptographic Digest Engine

<div align="center">

```
================================================================================
                                oohash
               Sovereign openOODA Multi-Algorithm Hasher
================================================================================
```

**Sovereign Multi-Algorithm Cryptographic Digest Engine**  
*Calculates BLAKE3, SHA-256, and SHA3-512 hashes simultaneously in a single pass.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure native [openOODA](https://openooda.org).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oohash/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oohash-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oohash/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oohash/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oohash-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oohash/uninstall.sh | bash
```

---

## 2. CLI Usage

```
Usage: oohash [OPTIONS] [FILE...]

Simultaneous multi-algorithm cryptographic hash calculator and integrity validator.

Options:
  -a, --algo <NAME>   Select algorithm: blake3, sha256, sha3_512, all (default: all)
      --tag           Create BSD-style checksum output
  -r, --raw           Print only raw hexadecimal digest without filename
  -c, --check <FILE>  Read checksums from FILE and check them
  -z, --zero          End each output line with NUL, not newline
  -j, --json          Emit RFC 8259 structured JSON output
  -D, --demo          Run interactive multi-algorithm cryptographic showcase
      --no-color      Disable ANSI color sequences
      --test          Run automated internal self-test suite
      --mcp           Launch streaming JSON-RPC 2.0 stdio server
  -h, --help          Display this help and exit
  -v, --version       Display version information and exit
```

---

## 3. Cryptographic Engines

`oohash` provides simultaneous single-pass calculation across three foundational hash families:
1. **BLAKE3**: 256-bit tree-structured cryptographic hash with 7 rounds of nonlinear quarter-round permutation mixing.
2. **SHA-256 (NIST FIPS 180-4)**: Industry standard 256-bit secure hash algorithm with 64 compression rounds.
3. **SHA3-512 (NIST FIPS 202)**: Next-generation Keccak-p[1600, 24] sponge permutation producing 512-bit security.

---

## 4. Model Context Protocol (MCP)

When invoked with `--mcp`, `oohash` runs a JSON-RPC 2.0 stdio server providing structured tools for AI coding agents:

```bash
oohash --mcp
```

### Registered MCP Tools:
* `hash_digest`: Ingests `text` and optional `algo`, returning computed cryptographic digests.
* `hash_file`: Reads `path` under `FsReadCap` and optional `algo`, returning file digest results.
* `hash_verify`: Asserts integrity of `path` or `text` against `expected` checksum.
* `hash_benchmark`: Queries algorithm parameters, round counts, and digest lengths.
* `hash_demo`: Executes the multi-algorithm cryptographic showcase and returns verification proof.

---

## 5. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation, bounded buffers, and deterministic verification.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 6. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
