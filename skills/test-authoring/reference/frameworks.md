# Test Framework Reference

Per-language commands, patterns, and coverage tooling.

## Python (pytest)

### Run Tests
```bash
# All tests
uv run pytest

# Specific file
uv run pytest tests/test_auth.py

# Specific test
uv run pytest tests/test_auth.py::test_login_success

# Verbose output
uv run pytest -v

# Stop on first failure
uv run pytest -x
```

### Coverage
```bash
# Run with coverage
uv run pytest --cov=src --cov-report=term-missing

# HTML report
uv run pytest --cov=src --cov-report=html

# Fail if below threshold
uv run pytest --cov=src --cov-fail-under=80
```

### Test File Pattern
```python
# tests/test_<module>.py
import pytest
from mypackage.module import function_under_test

class TestFunctionUnderTest:
    def test_happy_path(self):
        result = function_under_test("valid_input")
        assert result == expected_value

    def test_edge_case_empty(self):
        result = function_under_test("")
        assert result is None

    def test_error_invalid_input(self):
        with pytest.raises(ValueError, match="must be non-empty"):
            function_under_test(None)

# Fixtures for shared setup
@pytest.fixture
def sample_data():
    return {"key": "value"}

def test_with_fixture(sample_data):
    assert process(sample_data) == expected
```

### Mocking (Python)
```python
from unittest.mock import patch, MagicMock

# Mock a network call
def test_fetch_user():
    mock_response = MagicMock()
    mock_response.read.return_value = b'{"name": "Alice"}'
    mock_response.__enter__ = lambda s: s
    mock_response.__exit__ = MagicMock(return_value=False)

    with patch("mypackage.fetcher.urllib.request.urlopen", return_value=mock_response):
        result = fetch_user(1)
    assert result["name"] == "Alice"

# Mock with pytest monkeypatch
def test_with_monkeypatch(monkeypatch):
    monkeypatch.setenv("API_KEY", "test-key")
    result = get_config()
    assert result.api_key == "test-key"
```

## JavaScript/TypeScript (vitest)

### Run Tests
```bash
# All tests
pnpm vitest run

# Watch mode
pnpm vitest

# Specific file
pnpm vitest run src/auth.test.ts

# With UI
pnpm vitest --ui
```

### Coverage
```bash
# Run with coverage
pnpm vitest run --coverage

# Fail if below threshold (configure in vitest.config.ts)
```

### Test File Pattern
```typescript
// src/<module>.test.ts
import { describe, it, expect, vi } from 'vitest';
import { functionUnderTest } from './module';

describe('functionUnderTest', () => {
  it('returns expected value for valid input', () => {
    const result = functionUnderTest('valid');
    expect(result).toBe(expectedValue);
  });

  it('throws on invalid input', () => {
    expect(() => functionUnderTest(null)).toThrow('must be non-empty');
  });

  it('handles async operations', async () => {
    const result = await asyncFunction();
    expect(result).toMatchObject({ status: 'ok' });
  });
});
```

## JavaScript/TypeScript (jest)

### Run Tests
```bash
pnpm jest
pnpm jest --testPathPattern=auth
pnpm jest --watch
```

### Coverage
```bash
pnpm jest --coverage
pnpm jest --coverage --coverageThreshold='{"global":{"branches":80}}'
```

### Test File Pattern
Same as vitest but import from `@jest/globals` or use global `describe`/`it`/`expect`.

## Rust (cargo test)

### Run Tests
```bash
# All tests
cargo test

# Specific test
cargo test test_name

# Specific module
cargo test module_name::

# Show output from passing tests
cargo test -- --nocapture

# Run ignored tests
cargo test -- --ignored
```

### Coverage
```bash
# Using cargo-tarpaulin
cargo tarpaulin --out Html
cargo tarpaulin --fail-under 80
```

### Test File Pattern
```rust
// Inline unit tests (same file as source)
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_happy_path() {
        let result = function_under_test("valid");
        assert_eq!(result, expected_value);
    }

    #[test]
    #[should_panic(expected = "must be non-empty")]
    fn test_error_on_empty() {
        function_under_test("");
    }

    #[test]
    fn test_edge_case() {
        assert!(function_under_test("edge").is_none());
    }
}

// Integration tests go in tests/ directory
// tests/integration_test.rs
use mycrate::public_api;

#[test]
fn test_full_workflow() {
    let result = public_api::process("input");
    assert_eq!(result.status, Status::Complete);
}
```

## Go (go test)

### Run Tests
```bash
# All tests
go test ./...

# Specific package
go test ./pkg/auth/

# Verbose
go test -v ./...

# Run specific test
go test -run TestLogin ./pkg/auth/
```

### Coverage
```bash
# With coverage
go test -cover ./...

# Coverage profile
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Test File Pattern
```go
// module_test.go (same package)
package auth

import "testing"

func TestLogin_ValidCredentials(t *testing.T) {
    result, err := Login("user", "pass")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if result.Token == "" {
        t.Error("expected non-empty token")
    }
}

func TestLogin_InvalidPassword(t *testing.T) {
    _, err := Login("user", "wrong")
    if err == nil {
        t.Fatal("expected error for invalid password")
    }
}
```
