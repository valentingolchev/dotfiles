# Go + standard library testing profile

Load this profile together with the parent EXACT Coding Predictive TDD skill when the project uses Go with the standard library `testing` package and the `go` toolchain.

## Discover project commands first

Read `go.mod` before the first cycle and respect its Go version, module path, dependencies, and any project scripts or CI commands. Typical gates are:

```bash
go test ./...
go vet ./...
```

Not every project declares every tool. Use the full `go test ./...` invocation as the complete-suite command (`go test -count=1 ./...` at cycle closure, see Predictive phase gate). Where another gate has no declared command but its tool is installed (`staticcheck`, `gocyclo`, `gocognit`), invoke it directly; where the tool is absent, skip it rather than inventing an invocation.

Do not add dependencies the project has not declared, do not change the Go version in `go.mod`, and do not relax lint or vet settings to make a check pass.

## Source and test layout

Follow the package layout already established by the project. In a conventional module:

- production code lives in packages beside their files, with the package name matching the directory
- tests live in the same package in `*_test.go` files
- a test file mirrors the file or behavior under test, commonly `feature.go` and `feature_test.go`
- external black-box tests may use `package feature_test` when the project already does; otherwise keep the same package and use unexported access only from in-package tests

Keep test-only helpers in `*_test.go` files. Do not export production identifiers solely for tests, and do not restructure packages as unrelated cleanup.

## Test-list convention

Represent future examples as subtests marked with `t.Skip`. Activate exactly one behavior per cycle by removing that `t.Skip` line from exactly one subtest and adding its first observation in the same edit. A subtest whose body has no assertion passes vacuously — that is a silent pass, not a behavioral RED, so never activate by removing `t.Skip` alone.

For the up-front Test List phase, create the complete test file with inactive entries only:

```go
package feature

import "testing"

func TestFeature(t *testing.T) {
	t.Run("handles the first behaviour", func(t *testing.T) {
		t.Skip("TODO: expected result from the specification")
		// Red entry: remove t.Skip and add the assertion here in the same edit.
	})

	t.Run("handles the next behaviour", func(t *testing.T) {
		t.Skip("TODO: next expected result from the specification")
		// Red entry: remove t.Skip and add the assertion here in the same edit.
	})

	t.Run("verification", func(t *testing.T) {
		t.Run("handles the combination", func(t *testing.T) {
			t.Skip("TODO: combination result from the specification")
			// Activation: remove t.Skip and add the assertion in the same edit.
		})
	})
}
```

Place the verification tests after all driving tests, inside a subtest group named exactly `verification`. The workflow refers to the group by this name; do not translate or extend it.

Moving a test into the verification group means moving its skipped `t.Run` block into that `verification` group before activating it.

Use `t.Run` subtests, table-driven tests where the specification lists many concrete examples, plain `if got != want { t.Errorf(...) }` assertions, and `t.Fatal`/`t.Fatalf` only for setup-like failures where no meaningful assertion is possible. Keep every future behavior skipped; do not use commented-out tests, empty subtests without `t.Skip`, build tags, or `-run` filters as the test list.

## Interpret RED correctly

Inspect the `go test` output before comparing it with the prediction:

1. distinguish a compile error from a test failure
2. distinguish an unresolved identifier, missing method, or type mismatch from an assertion failure
3. inspect the assertion's `got` and `want` values, failure messages, and any panic stack
4. record tests passed, failed, and skipped for every package `go test` ran

A missing function, method, or type fails during compilation with `undefined: ...`, and `go test` then runs no tests for that package; do not call that an assertion failure. A package that fails to compile can stop the run before later packages execute, so confirm which packages actually ran before reading counts. A compile error is a valid first RED only when it is the intended failure for the current baby step; otherwise revert and choose a smaller or corrected step.

When an activated example is already satisfied by an earlier generalization, follow the already-green exception in the parent skill: predict the passing result, run the suite, record that no production change is needed, and continue without manufacturing a failure.

## Go-oriented GREEN progression

Let the implementation emerge one active example at a time. Typical small steps include:

1. a package, function signature, or type sufficient to compile
2. an intentionally wrong result, zero value, or `panic("TODO")` only long enough to reach behavioral RED
3. a hardcoded return for the first GREEN
4. use of an input parameter
5. a narrow `if` branch
6. named domain constants or extracted functions when another example forces them
7. a general expression, map, slice operation, or interface only when demanded by active behavior
8. explicit validation and returned `error` values only when required by the specification

Do not jump to an interface, generic, struct, or goroutine because Go makes it short to write. Keep domain names even when a parameter is temporarily unused; use `_` only where the project already does. Prefer returning `error` over `panic` in production code unless the specification defines a panic as the observable behavior.

The compiler and `go vet` check types and many misuse patterns before tests run, so let compile errors guide the shape of a call. Treat them as information, not noise to silence.

## Go-oriented SRP review

Apply the parent Predictive TDD skill's Single Responsibility Principle at Go boundaries. Keep domain decisions in the domain package and separate from adapters such as CLI parsing, HTTP transport, JSON with `encoding/json`, filesystem access, and persistence. Prefer a cohesive function or small package whose name states one responsibility; extract a collaborator when separate concerns would change for separate reasons. Prefer plain functions to structs when there is no state to hold, prefer concrete types unless an interface names a real boundary, and do not introduce a generic, interface, or design pattern without a concrete responsibility in the current code.

## Formatting, vet, and smell checks

Use the project's declared quality commands first. Common gates are:

```bash
gofmt -l .
go vet ./...
```

`gofmt -l .` is clean when it prints no file names. When installed and configured, also use smell and complexity tools as evidence for the Four Rules review, in machine-readable form where the tool supports it:

```bash
staticcheck -f json ./...
gocyclo -over 10 .
gocognit -json .
```

Use each tool's machine-readable flag when supported; otherwise record its default output verbatim. Note `gocyclo` has no JSON flag — its flags are `-over`, `-top`, `-avg`, `-ignore` — so use its plain output. These findings are evidence, not permission to change observable behavior. Allow concrete literals in test examples when they express specification inputs and outputs; prefer named domain constants in production code when literals duplicate knowledge.

Do not weaken vet, staticcheck, or complexity thresholds globally to make a check pass, and do not silence a finding with a broad suppression where a narrow, item-level reason exists. Keep test-specific concessions scoped to `_test.go` files where the project's tooling allows.

## Predictive phase gate

Before every deterministic check, state a falsifiable expectation and run the check immediately. Use the smallest relevant `go test` invocation during diagnosis and the complete suite for cycle closure:

```bash
go test ./... -run 'TestFeature'
go test -count=1 ./...
```

Go caches passing test results per package; `-count=1` disables that cache so every cycle-closure run actually re-executes the suite and the check stays deterministic.

Run focused commands from the package directory when a name is not unique across the module. To activate one subtest only, match the top-level test and subtest path, accounting for spaces becoming underscores in `-run` output names.

- **RED:** continue only when the active behavior fails for the predicted reason; investigate a mismatch rather than changing production behavior.
- **GREEN:** retain the change only when the complete suite passes.
- **REFACTOR:** run the complete suite and applicable format, vet, and smell gates; retain a structural trial only when all pass and intent improves, otherwise narrowly undo that trial.

Do not create method commits or use hard resets as phase transitions. Before completion, run every applicable project-defined quality gate in the established order. Record Go's exact package results and distinguish compile errors, failures, skips (`--- SKIP`), and passes.
