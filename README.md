# ITPay CLI

Open-source CLI and agent skill for VoltaGent / ITPay agent-native model packages.

This repository contains only the local CLI and skill files. It does not include the closed-source SaaS backend.

## Install

After the package is published:

```bash
npm install -g itpay_cli
```

Then verify:

```bash
itp --version
itp auth status --json
```

You can also run it without global install:

```bash
npx itpay_cli --version
```

## API Endpoint

By default the CLI talks to `http://localhost:3000`, which is useful for local development.

Set `VOLTAGENT_API_BASE` for staging or production:

```bash
export VOLTAGENT_API_BASE=https://your-voltagent-api.example.com
```

## Common Flow

Register an agent-native account:

```bash
itp auth register --runtime codex --json
```

Set the first Web login password:

```bash
printf 'your-password\n' | itp account set-password --password-stdin --json
```

List plans:

```bash
itp plans --json
```

Create a checkout:

```bash
itp checkout create --plan coding-100 --method alipay --json
```

Wait for verified payment and grant delivery:

```bash
itp payment wait <checkout_id> --json
```

Install a grant into a runtime:

```bash
itp grants install <grant_id> --target codex --json
itp install codex --grant <grant_id> --json
```

Supported targets:

```text
codex
claude-code
openclaw
```

## Safety Rules

- Use `--password-stdin`; never pass passwords as command-line arguments.
- The CLI does not print session tokens.
- The CLI stores session tokens and grant keys in macOS Keychain or Linux `secret-tool` when available.
- If native credential storage is unavailable, it falls back to `~/.itp/credentials.json` with `0600` permissions.
- Do not paste gateway API keys into chat.

## Agent Skill

The Codex skill is included at:

```text
skills/voltagent/SKILL.md
```

Agents can use this skill to run the checkout, payment wait, grant install, runtime install, and diagnosis flow.

## Local Development

Run static and smoke checks:

```bash
npm run check
```

Run against a local backend:

```bash
VOLTAGENT_API_BASE=http://localhost:3000 ./e2e-local.sh
```

The E2E script uses a temporary HOME so it does not touch your real `~/.itp` or `~/.codex`.

## Publish Checklist

```bash
npm run check
npm pack --dry-run
npm publish
```
