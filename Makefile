IDRIC ?= idris2
IDRIC_SOURCES := $(wildcard Mt/*.idric tests/*.idric) Mt.idric

.PHONY: all test check-vocabulary clean

all: check-vocabulary
	$(IDRIC) --build prowide-core.ipkg

check-vocabulary:
	@if grep -nE '(^|[^[:alnum:]_])Nat([^[:alnum:]_]|$$)' $(IDRIC_SOURCES); then \
		echo 'error: active Edriç source must use ℕ for natural numbers' >&2; \
		exit 1; \
	fi

test: all
	$(IDRIC) tests/MtTests.idric -o prowide-core-edric-tests
	./build/exec/prowide-core-edric-tests

clean:
	rm -rf build
