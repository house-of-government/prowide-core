# Edriç translation

This fork is being translated from the Java Prowide Core implementation into Edriç.

The active Edriç API is deliberately visible at the repository top level through `Mt.idric`. The existing Java implementation remains in place as a completeness and regression oracle while behavior is ported; new message behavior belongs in Edriç rather than in a second Java implementation.

## Scope

Translate the message library, not the SWIFT network stack:

1. FIN envelope blocks 1–5.
2. Generic MT field parsing and writing, including continuation lines.
3. Typed MT messages for categories 1–9.
4. Shared BIC/account primitives, including registered IBAN length and MOD97 checksum validation.
5. FIN/RJE reading and writing.
6. Message-model conversions needed by the companion ISO 20022 translation, only after both message models are independently stable.

JSON, proprietary XML, JPA, Gradle, Maven publication, and Java compatibility layers are reference behavior, not architectural requirements for Edriç.

## Porting rule

Do not hand-translate thousands of generated Java classes. Treat checked-in generated Java and checked-in data files as schema/completeness input. Extract field/message definitions into generated Edriç declarations or compact Edriç schema data. Keep hand-written parsing, writing, validation, and translation logic small and inspectable.

## Shared identifier boundary

`PaymentIdentifiers.idric` is the common domain boundary consumed by this MT slice and the companion ISO 20022 draft. It has its own `prowide_identifiers_edric` package (`prowide-identifiers.ipkg`). `prowide_core_edric` depends on that package rather than owning the identifier module, and the MX package depends on the same identifier package directly. MX therefore does not acquire a dependency on MT message types, FIN parsing, or the rest of Prowide Core merely to use BIC/account values.

The boundary is intentionally one small Edriç module, not a translation of Prowide's Java classes or JAXB graph. It currently provides:

- `Bic`, preserving the exact 8- or 11-character text.
- `parse_bic`, implementing the ISO 9362 / ISO 20022 structural BIC shape.
- `parse_fin_bic`, adding FIN's stricter four-letter party prefix for message fields such as option A.
- `Account`, a non-empty single-line account identifier with no inferred scheme.
- `Iban validity`, indexed by `iban_valid text`; `ValidIban` is `Iban True`.
- `AccountIdentification`, whose `IbanAccount` constructor accepts only `ValidIban`, while `OtherAccount` carries an ordinary account identifier.
- `parse_iban` / `iban_account`, validating the IBAN's two-letter country prefix, two check digits, alphanumeric BBAN text, the fixed country length from SWIFT IBAN Registry release 102 (June 2026), and the MOD97-10 checksum.

The indexed `Iban` type makes the validation state part of the type rather than merely returning a Boolean beside a string. `MkIban text` has type `Iban (iban_valid text)`, so text for which the shared predicate is false cannot be supplied to `IbanAccount`, whose argument is `Iban True`.

Deliberate non-claims in this slice:

- BIC parsing is structural only. It does not query the BIC Directory, prove that a country code is assigned, or prove that a BIC is registered/current.
- IBAN validation does not yet validate each country's internal BBAN subfields (bank-code length, branch-code character class, account-number layout, and similar domestic rules). `src/main/resources/BbanStructureValidations.json` remains the source candidate for that separate slice.
- FIN account text is never guessed to be an IBAN. Option A contributes an `OtherAccount` plus a validated FIN BIC even when the account text happens to look like a valid IBAN.
- No MT ↔ MX field mapping or translation is introduced by this boundary.

Public structure references: SWIFT's BIC description at `https://www.swift.com/standards/data-standards/bic-business-identifier-code`, SWIFT's IBAN Registry, and the ISO 15022 option-A format examples at `https://www.iso20022.org/15022/uhb/mtn91-5-field-57a.htm`.

## Current executable slice

`Mt.Types` defines the lossless generic FIN envelope plus the first typed MT103 semantic projection. Field 32A is split into date, currency, and exact textual amount; mandatory 50A/F/K and 59A/F/no-option choices are represented as alternatives rather than collapsed to strings. Option A now exposes only the structure FIN itself gives us: an optional shared `AccountIdentification` plus BIC. F/K/F/no-option content remains raw.

`Mt.Schema` contains the complete SRU 2025 MT103 field grammar extracted from Prowide's generated `MT103.java`: mandatory/optional groups, alternatives, and repetitive fields. Its validator rejects unknown fields, missing mandatory groups, and multiple members of single-choice groups.

`Mt.Parse` reads blocks 1–5 with balanced nested braces, parses block 4 fields, and preserves continuation lines. `Mt.Fin` writes the generic representation back to FIN. `Mt.Typed` validates generic MT103 content against the schema before decoding its mandatory semantic fields and routes option-A BIC/account content through the shared boundary without inferring an account scheme.

`tests/MtTests.idric` fixes exact FIN output, generic parse/write round trips, optional blocks 3/5, multiline fields, MT103 alternatives/repetition rules, typed 50/59 alternatives, exact field-32A components, BIC/account boundary behavior, registered-length/checksum IBAN acceptance and refusal, explicit refusal to infer IBAN from FIN account text, refusal of 12-character logical-terminal addresses where a BIC is required, and rejection of non-MT103 block-2 content.

Run:

```sh
make test
```

The Makefile builds and installs `prowide_identifiers_edric` before compiling the MT package, so the package boundary is exercised rather than satisfied by same-package visibility.

## Next generated slices

1. Validate field order as well as membership/cardinality.
2. Give block 1 and block 2 typed header/direction representations; keep their 12-character logical-terminal addresses distinct from BIC values.
3. Add country-specific BBAN subfield validation from `src/main/resources/BbanStructureValidations.json` without duplicating it into MT and MX.
4. Add RJE framing and multi-message input.
5. Extract the remaining generated MT message grammars and generated field component definitions into Edriç schema/model data.
6. Only after the shared primitives and both message-side models are stable, add explicit MT ↔ MX translation cases.
