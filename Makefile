# ==============================================================================
# oohash: Sovereign Multi-Algorithm Cryptographic Digest Engine
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oohash
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oohash-linux-x86_64
	@cd dist && sha256sum oohash-linux-x86_64 > oohash-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oohash-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oohash" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) -v | grep -q "oohash 0.2.0" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "OK: all tests passed" && echo "PASS: internal anchors"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "Sovereign Century Tool" && echo "PASS: --demo"
	@echo "=== testing multi-hash calculation and verification ==="
	@printf "abc" > dist/fixture.txt
	@./$(BIN) -a sha256 -r dist/fixture.txt | grep -q "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" && echo "PASS: sha256 calculation"
	@./$(BIN) -a sha3_512 -r dist/fixture.txt | grep -q "b751850b1a57168a5693cd924b6b096e08f621827444f70d884f5d0240d2712e10e116e9192af3c91a7ec57647e3934057340b4cf408d5a56592f8274eec53f0" && echo "PASS: sha3_512 calculation"
	@./$(BIN) --tag -a sha256 dist/fixture.txt | grep -q "SHA256 (dist/fixture.txt)" && echo "PASS: BSD tag style"
	@echo "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad  dist/fixture.txt" > dist/manifest.txt
	@./$(BIN) --no-color -c dist/manifest.txt | grep -q "dist/fixture.txt: OK" && echo "PASS: manifest check"
	@rm -f dist/fixture.txt dist/manifest.txt
	@echo "=== testing MCP initialize ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | ./$(BIN) --mcp | grep -q "hash_digest" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call hash_digest ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"hash_digest","arguments":{"text":"abc"}}}' | ./$(BIN) --mcp | grep -q "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" && echo "PASS: MCP hash_digest"
	@echo "=== testing MCP tools/call hash_demo ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"hash_demo","arguments":{}}}' | ./$(BIN) --mcp | grep -q "Sovereign Century Tool" && echo "PASS: MCP hash_demo"
	@echo "=== testing MCP tools/call hash_benchmark ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"hash_benchmark","arguments":{}}}' | ./$(BIN) --mcp | grep -q "algorithms" && echo "PASS: MCP hash_benchmark"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oohash
	@chmod 0755 dist/deb-root/usr/bin/oohash
	@cp uninstall.sh dist/deb-root/usr/bin/oohash-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oohash-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oohash_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oohash_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oohash-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oohash.spec > ~/rpmbuild/SPECS/oohash.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oohash.spec
	@cp ~/rpmbuild/RPMS/x86_64/oohash-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oohash
	@chmod 0755 dist/arch-pkg/usr/bin/oohash
	@cp uninstall.sh dist/arch-pkg/usr/bin/oohash-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oohash-uninstall
	@printf "pkgname = oohash\npkgbase = oohash\npkgver = $(VERSION)-1\npkgdesc = Sovereign multi-algorithm cryptographic digest engine in pure openOODA.\nurl = https://github.com/openOODA-tools/oohash\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oohash\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oohash-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oohash-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cp $(BIN) dist/oohash-linux-x86_64
	@cd dist && sha256sum oohash-linux-x86_64 > oohash-linux-x86_64.sha256
	@cd dist && sha256sum oohash* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
