# Copilot Tool Configuration

## RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

### Rule

Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

Do not apply this prefix inside generated shell script files (`.sh`) unless explicitly requested.

### Meta commands (use directly)

```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```

## Dart MCP Tooling Discipline

Flutter and Dart work MUST use the Dart MCP toolchain whenever a supported tool exists; shell commands are fallback only when no tool covers the task.
- Runtime and app control MUST prefer these tools:
  - `mcp_dart_sdk_mcp__connect_dart_tooling_daemon`
  - `mcp_dart_sdk_mcp__create_project`
  - `mcp_dart_sdk_mcp__hot_reload`
  - `mcp_dart_sdk_mcp__hot_restart`
  - `mcp_dart_sdk_mcp__stop_app`
- Debugging and runtime inspection MUST use these tools:
  - `mcp_dart_sdk_mcp__get_runtime_errors`
  - `mcp_dart_sdk_mcp__flutter_driver`
- Pub.dev package operations MUST use `mcp_dart_sdk_mcp__pub` for dependency
  management, including `add`, `get`, `remove`, `upgrade`, `deps`, and
  `outdated`.
- Pub.dev package discovery/search MUST happen before dependency changes by
  checking the package catalog on pub.dev or the closest available discovery
  tool, so package selection is based on current package metadata rather than
  guesswork.
- Repository search MUST use workspace search tools instead of shell search:
  - `semantic_search`
  - `grep_search`
  - `file_search`
- If no MCP tool covers the task, the smallest necessary fallback MAY be used,
  but the gap and fallback reason MUST be stated before proceeding.
