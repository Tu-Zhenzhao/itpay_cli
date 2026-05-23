---
name: voltagent
description: >
  Use VoltaGent when the user asks to buy, recharge, configure, install, check,
  or use LLM model packages through VoltaGent. This skill controls the itp CLI
  to register/login, create checkout, wait for verified payment, install grants,
  and configure Claude Code, Codex, or OpenClaw.
---

# VoltaGent Skill

Use this skill when the user says things like:

- 用 VoltaGent 买 100 元 coding 模型包并配置好
- 给 Claude Code 配一个模型包
- 帮我充值 VoltaGent
- 查看 VoltaGent 余额
- 安装 VoltaGent 到 Codex / Claude Code / OpenClaw
- 为 agent-native 无密码账号首次设置 Web 登录密码

## Rules

1. Do not invent payment links or QR codes.
2. Do not modify, summarize, shorten, or rewrite Alipay cashier URLs.
3. Do not treat the user's statement "I paid" as payment verification.
4. Only `itp payment wait` returning `grant_issued` means the service can be installed.
5. Do not ask the user to paste API keys into chat.
6. Do not print secrets, API keys, or grant credentials.
7. Use `--json` for all itp commands when acting as an agent.
8. Store credentials only through itp/keychain.
9. For password login or setup, use `--password-stdin`; never pass passwords as command-line arguments.
10. If an official Alipay payment skill is available and a cashier URL is returned, invoke it.
11. If the Alipay payment skill is not installed, ask user permission to install the official Alipay payment skill.

## Flow

1. Check itp:
   `which itp || ./cli/itp/bin/itp --version`

2. Check auth:
   `itp auth status --json`

3. If not logged in:
   `itp auth register --runtime <current-runtime> --json`

4. List plans:
   `itp plans list --json`

5. Select plan according to user intent:
   default for "100 元 coding 模型包" is `coding-100`.

6. Create checkout:
   `itp checkout create --plan coding-100 --method alipay --json`

7. If response contains `payment.cashier_url`:
   invoke the official Alipay payment skill with the cashier URL.
   The URL must be preserved character-for-character.

8. Wait for verified payment:
   `itp payment wait <checkout_id> --json`
   This command actively calls checkout recover when payment is verified but grant delivery is still pending.
   If local state was lost and the checkout ID is unknown, run
   `itp checkout list --limit 20 --json` and recover the latest matching checkout instead of creating a duplicate order.

9. If grant issued:
   `itp grants install <grant_id> --target <current-runtime> --json`

10. Configure client:
    `itp install <current-runtime> --grant <grant_id> --json`
    Install performs a `/models` connectivity check by default. Use `--offline` only when network access is intentionally unavailable.

11. If install reports `model_check.ok=false`, diagnose:
    `itp doctor --target <current-runtime> --grant <grant_id> --json`

12. Report:
    show installed target, base_url, active models, remaining credits, and Web console login link if available.

## Root Operations

Only use these with an explicit root/admin troubleshooting request:

- `itp admin orders --json --access-token <root_token> --new-api-user <id>`
- `itp admin payment-events --json --access-token <root_token> --new-api-user <id>`
- `itp admin outbox --json --access-token <root_token> --new-api-user <id>`
- `itp admin process-outbox --json --access-token <root_token> --new-api-user <id>`
- `itp admin recover-order <order_id> --json --access-token <root_token> --new-api-user <id>`

Never expose raw payment payloads or credentials in troubleshooting output.
