# Security Checklist

Check every item against the code under review. Any match at Critical level is an immediate blocker.

## Critical: OWASP Top 10

### 1. Injection (SQL, Command, LDAP)
- Are database queries parameterized? No string concatenation with user input.
- Are shell commands built without user input? If user input is needed, use allowlists.
- Are LDAP/XPath queries using safe APIs?

**Pattern to flag:**
```python
# BAD: SQL injection
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
os.system(f"convert {filename}")

# GOOD: parameterized
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
subprocess.run(["convert", filename])  # list form, no shell
```

### 2. Broken Authentication
- New endpoints require authentication.
- Password comparison uses constant-time comparison.
- Session tokens have proper expiry.
- No credentials in URL parameters.

### 3. Sensitive Data Exposure
- No secrets, API keys, or passwords in code.
- Sensitive data encrypted at rest and in transit.
- PII not logged or exposed in error messages.
- `.env` files in `.gitignore`.

### 4. XML External Entities (XXE)
- XML parsers disable external entity processing.
- Use `defusedxml` (Python) or equivalent safe parsers.

### 5. Broken Access Control
- Authorization checked for every resource access.
- Users cannot access other users' data by changing IDs.
- Admin routes protected by role checks.
- File uploads validated and sandboxed.

### 6. Security Misconfiguration
- Debug mode disabled in production configs.
- Default credentials changed.
- Error messages do not leak stack traces to users.
- CORS configured restrictively.

### 7. Cross-Site Scripting (XSS)
- User input sanitized before rendering in HTML.
- Template engines auto-escape enabled.
- `dangerouslySetInnerHTML` (React) or equivalent flagged for review.
- Content-Security-Policy headers set.

### 8. Insecure Deserialization
- No `pickle.loads()`, `eval()`, or `yaml.load()` (use `yaml.safe_load()`).
- JSON deserialization validates schema before use.
- No deserialization of untrusted data without validation.

### 9. Using Components with Known Vulnerabilities
- Dependencies pinned to specific versions.
- No obviously outdated libraries with known CVEs.
- Lock files committed.

### 10. Insufficient Logging and Monitoring
- Security-relevant actions logged (auth failures, permission denials).
- Logs do not contain sensitive data (passwords, tokens).
- Log injection prevented (newlines stripped from user input in logs).

## Language-Specific Checks

### Python
- No `eval()`, `exec()`, `__import__()` with user input.
- No `shell=True` in `subprocess` calls.
- Use `secrets` module for token generation, not `random`.

### JavaScript/TypeScript
- No `eval()`, `Function()`, `innerHTML` with user input.
- No `child_process.exec()` with user input (use `execFile`).
- Dependencies audited: `pnpm audit`.

### Rust
- Unsafe blocks justified and minimal.
- No `unwrap()` on user-facing input paths.
- File paths validated against traversal.

### Go
- No `fmt.Sprintf` for SQL queries.
- `crypto/rand` used instead of `math/rand` for security-sensitive values.
- HTTP handlers check method before processing.

## File and Path Security
- File paths validated: no `../` traversal.
- Uploaded files: validated extension, MIME type, and size.
- Temporary files cleaned up.
- Symlink attacks considered for file operations.
