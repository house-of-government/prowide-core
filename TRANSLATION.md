# Edriç translation

This fork is being translated from the Java Prowide Core implementation into Edriç.

The active Edriç API is deliberately visible at the repository top level through `Mt.idric`. The existing Java implementation remains in place as a completeness and regression oracle while behavior is ported; new message behavior belongs in Edriç rather than in a second Java implementation.

## Scope

Translate the message library, not the SWIFT network stack:

1. FIN envelope blocks 1–5.
2. Generic MT field parsing and writing, including continuation lines.
3. Typed MT messages for categories 1–9.
4. BIC and IBAN value types and validation.
5. FIN/RJE reading and writing.
6. Message-model conversions needed by the companion ISO 20022 translation.

JSON, proprietary XML, JPA, Gradle, Maven publication, and Java compatibility layers are reference behavior, not architectural requirements for Edriç.

## Porting rule

Do not hand-translate thousands of generated Java classes. Treat checked-in generated Java and checked-in data files as schema/completeness input. Extract field/message definitions into generated Edriç declarations or compact Edriç schema data. Keep hand-written parsing, writing, validation, and translation logic small and inspectable.

## Current executable slice

`Mt.Types` defines the lossless generic FIN envelope plus the first typed MT103 semantic projection. Field 32A is split into date, currency, and exact textual amount; mandatory 50A/F/K and 59A/F/no-option choices are represented as alternatives rather than collapsed to strings.

`Mt.Schema` contains the complete SRU 2025 MT103 field grammar extracted from Prowide's generated `MT103.java`: mandatory/optional groups, alternatives, and repetitive fields. Its validator rejects unknown fields, missing mandatory groups, and multiple members of single-choice groups.

`Mt.Parse` reads blocks 1–5 with balanced nested braces, parses block 4 fields, and preserves continuation lines. `Mt.Fin` writes the generic representation back to FIN. `Mt.Typed` validates generic MT103 content against the schema before decoding its mandatory semantic fields.

`tests/MtTests.idric` fixes exact FIN output, generic parse/write round trips, optional blocks 3/5, multiline fields, MT103 alternatives/repetition rules, typed 50/59 alternatives, exact field-32A components, and rejection of non-MT103 block-2 content.

Run:

```sh
make test
```

## Next generated slices

1. Validate field order as well as membership/cardinality.
2. Give block 1 and block 2 typed header/direction representations.
3. Translate BIC and IBAN validation, using `src/main/resources/BbanStructureValidations.json` as data rather than baking a partial country table into code.
4. Add RJE framing and multi-message input.
5. Extract the remaining generated MT message grammars and generated field component definitions into Edriç schema/model data.
6. Share BIC/IBAN/account primitives with the ISO 20022 translation and then add MT ↔ MX translations.
