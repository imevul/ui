# Imevul UI — CraftOS-PC harness
ROOT      := $(abspath .)
UI_DIR    := $(ROOT)/imevul/ui
DATA_DIR  := $(ROOT)/.craftos
SMOKE     := $(ROOT)/dev/smoke.lua
CRAFTOS   := $(firstword $(shell command -v craftos 2>/dev/null) $(shell command -v craftos-pc 2>/dev/null))
TIMEOUT   := $(shell command -v timeout 2>/dev/null)
SMOKE_SEC ?= 15

MOUNT     := --mount-ro /imevul/ui=$(UI_DIR)
COMMON    := --id 0 --directory $(DATA_DIR) $(MOUNT)

.PHONY: help run smoke

help:
	@echo "Imevul UI"
	@echo "  make run    — CraftOS-PC GUI, library mounted at /imevul/ui"
	@echo "  make smoke  — headless dofile + ui.App + quit"

run:
	@if [ -z "$(CRAFTOS)" ]; then echo "craftos / craftos-pc not on PATH" >&2; exit 1; fi
	@mkdir -p $(DATA_DIR)
	$(CRAFTOS) --single $(COMMON)

smoke:
	@if [ -z "$(CRAFTOS)" ]; then echo "craftos / craftos-pc not on PATH" >&2; exit 1; fi
	@mkdir -p $(DATA_DIR)
	@out=$$(mktemp); \
	if [ -n "$(TIMEOUT)" ]; then \
		$(TIMEOUT) --preserve-status $(SMOKE_SEC) $(CRAFTOS) --headless $(COMMON) --script $(SMOKE) >$$out 2>&1; \
		st=$$?; \
	else \
		$(CRAFTOS) --headless $(COMMON) --script $(SMOKE) >$$out 2>&1; \
		st=$$?; \
	fi; \
	if ! grep -q 'SMOKE_OK' $$out; then \
		echo "smoke failed (exit $$st); CraftOS-PC output:" >&2; \
		cat $$out >&2; \
		rm -f $$out; \
		exit 1; \
	fi; \
	rm -f $$out; \
	echo "SMOKE_OK"
