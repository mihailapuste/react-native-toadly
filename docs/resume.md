# Resume Notes

Scan date: 2026-06-04.

This document captures the current state of the project so work can resume without rediscovering the same context. Refresh the registry snapshot before editing package versions.

## Project Shape

- Root package: `react-native-toadly`, version `0.3.4`.
- Package manager: Yarn 3.6.1, checked in at `.yarn/releases/yarn-3.6.1.cjs`, with `nodeLinker: node-modules`.
- Workspace packages: root SDK package and `example/`.
- JavaScript entrypoint: `src/index.tsx`.
- Nitro spec: `src/Toadly.nitro.ts`.
- JavaScript services: logging, global error handling, and network monitoring under `src/services/`.
- Native implementations: Swift under `ios/`, Kotlin under `android/`.
- Generated Nitro bindings: committed under `nitrogen/generated/`.
- Example app: React Native app under `example/`, configured to use the local SDK package.

## Current Behavior

- `setup(githubToken, repoOwner, repoName)` configures GitHub issue submission.
- `show()` opens the native report UI and pushes recent JavaScript logs to native.
- Console logging is captured once the SDK is imported.
- Automatic JavaScript issue submission is opt-in through `enableAutomaticIssueSubmission(true)`.
- Network monitoring wraps `fetch` and `XMLHttpRequest`.
- `crashNative()` intentionally crashes iOS and Android for testing.
- Manual iOS reports can include screenshots. Android reports do not yet attach screenshots.

## Local Environment Observations

- `.nvmrc` pins Node `v20`.
- During this scan, the shell was using Node `v24.14.0`.
- `yarn`, `npm`, and `corepack` were not on PATH in this shell.
- The checked-in Yarn release works with `node .yarn/releases/yarn-3.6.1.cjs`.

Useful fallback commands:

```sh
node .yarn/releases/yarn-3.6.1.cjs install
node .yarn/releases/yarn-3.6.1.cjs typecheck
node .yarn/releases/yarn-3.6.1.cjs lint
node .yarn/releases/yarn-3.6.1.cjs test
node .yarn/releases/yarn-3.6.1.cjs example start
node .yarn/releases/yarn-3.6.1.cjs example ios
node .yarn/releases/yarn-3.6.1.cjs example android
```

## Package Baseline

Important package versions currently declared in the manifests:

| Package | Current | Registry latest from scan |
| --- | ---: | ---: |
| `react-native` | `0.78.1` | `0.85.3` |
| `react` | `19.0.0` | `19.2.7` |
| `@react-native-community/cli` | `15.0.1` | `20.1.3` |
| `@react-native/babel-preset` | `0.78.1` | `0.85.3` |
| `@react-native/metro-config` | `0.78.1` | `0.85.3` |
| `@react-native/typescript-config` | `0.78.1` | `0.85.3` |
| `@react-native/eslint-config` | `^0.78.0` | `0.85.3` |
| `react-native-nitro-modules` | `^0.25.2` | `0.35.9` |
| `nitro-codegen` | `^0.25.2` | `0.29.4` |
| `react-native-builder-bob` | `^0.39.0` | `0.41.0` |
| `typescript` | `^5.2.2` | `6.0.3` |
| `eslint` | `^9.22.0` | `10.4.1` |
| `jest` | `^29.7.0` | `30.4.2` |
| `turbo` | `^1.10.7` | `2.9.16` |
| `axios` | `^1.8.4` | `1.17.0` |

The current React Native package latest declares a Node engine of `^20.19.4 || ^22.13.0 || ^24.3.0 || >= 25.0.0`. The repo's `v20` pin may need to become more specific before upgrading.

## Modernization Plan

1. Treat React Native as a native template migration, not a plain `package.json` bump. Use React Native Upgrade Helper for `0.78.1` to the target latest version and apply example app changes to Android, iOS, Metro, Babel, and TypeScript config.
2. Upgrade the React Native family together in the root and example manifests: `react`, `react-native`, `@react-native/*`, and `@react-native-community/cli*`.
3. Upgrade Nitro separately. `react-native-nitro-modules` and `nitro-codegen` do not share the same latest version, so verify compatibility before changing both. Regenerate bindings with `yarn nitrogen` and review `nitrogen/generated`.
4. Upgrade library tooling after the native stack builds: Bob, TypeScript, ESLint, Jest, release tooling, and Turbo.
5. Reinstall iOS pods from `example/ios` and rebuild both platforms.
6. Run `typecheck`, `lint`, `test`, and at least one iOS or Android example build before considering the modernization complete.

## Known Gaps

- `src/__tests__/index.test.tsx` only contains `it.todo('write a test')`.
- README and example docs now describe network monitoring as implemented, but there are no tests around the wrappers.
- GitHub credentials are configured directly in `example/config.ts`; a safer `.env` flow would be better for future example work.
- Android screenshot attachment remains missing.
- Native crash reporting behavior should be verified after the package upgrade because React Native error and lifecycle internals can change across versions.
