IDRIC ?= idris2
IDRIC_SOURCES := PaymentIdentifiers.idric $(wildcard Mt/*.idric tests/*.idric) Mt.idric

.PHONY: all identifiers test check-vocabulary clean

all: check-vocabulary identifiers
	$(IDRIC) --build prowide-core.ipkg

identifiers:
	$(IDRIC) --build prowide-identifiers.ipkg
	$(IDRIC) --install prowide-identifiers.ipkg

check-vocabulary:
	@if grep -nE '(^|[^[:alnum:]_])Nat([^[:alnum:]_]|$$)' $(IDRIC_SOURCES); then \
		echo 'error: active Edriç source must use ℕ for natural numbers' >&2; \
		exit 1; \
	fi

test: all
	$(IDRIC) -p prowide_identifiers_edric tests/MtTests.idric -o prowide-core-edric-tests
	./build/exec/prowide-core-edric-tests

clean:
	rm -rf build
