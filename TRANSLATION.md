# Edriç translation

This fork is being translated from the Java Prowide Core implementation into Edriç.

The active Edriç API is deliberately visible at the repository top level through `Mt.idric`. The existing Java implementation remains in place as a completeness and regression oracle while behavior is ported; new behavior belongs in Edriç rather than in a second Java implementation.

## Scope

Translate the message library, not the SWIFT network stack:

1. FIN envelope blocks 1–5.
2. Generic MT field parsing and writing, including continuation lines.
3. Typed MT messages for categories 1–9, beginning with MT103.
4. BIC and IBAN value types and validation.
5. FIN/RJE reading and writing.
6. Message-model conversions needed by the companion ISO 20022 translation.

JSON, proprietary XML, JPA, Gradle, Maven publication, and Java compatibility layers are reference behavior, not architectural requirements for Edriç.

## Porting rule

Do not hand-translate thousands of generated Java classes. Extract the field/message definitions and generate or describe the equivalent Edriç data declarations from the source metadata. Hand-written parsing, writing, validation, and translation logic should remain small and inspectable.

## Current executable slice

`Mt.Types` defines a generic FIN envelope and the first typed message, MT103. `Mt.Fin` renders that model to FIN wire text. `Mt.Parse` reads blocks 1–5 with balanced nested braces, parses block 4 fields, and preserves continuation lines. `tests/MtTests.idric` fixes MT103 field order, exact wire output, generic FIN parse/write behavior, optional blocks 3/5, and multiline fields as acceptance behavior.

Run:

```sh
make test
```

The next correctness milestone is typed `SwiftEnvelope → MT103` validation, then block 2 direction/header types, BIC/IBAN types, RJE framing, and schema-derived generation for the remaining MT field/message declarations.
