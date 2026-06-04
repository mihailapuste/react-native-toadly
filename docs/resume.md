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

- `.nvmrc` pins Node `v20.19.4`.
- During this scan, the shell was using Node `v24.14.0`.
- `yarn`, `npm`, and `corepack` were not on PATH in this shell.
- The checked-in Yarn release works with `node .yarn/releases/yarn-3.6.1.cjs`.
- Android SDK exists at `/Users/mihailapuste/Library/Android/sdk`, but `ANDROID_HOME` was not exported in this shell.

Useful fallback commands:

```sh
node .yarn/releases/yarn-3.6.1.cjs install
node .yarn/releases/yarn-3.6.1.cjs typecheck
node .yarn/releases/yarn-3.6.1.cjs lint
node .yarn/releases/yarn-3.6.1.cjs test
node .yarn/releases/yarn-3.6.1.cjs example start
node .yarn/releases/yarn-3.6.1.cjs example ios
node .yarn/releases/yarn-3.6.1.cjs example android
ANDROID_HOME="$HOME/Library/Android/sdk" node .yarn/releases/yarn-3.6.1.cjs example build:android
node .yarn/releases/yarn-3.6.1.cjs example build:ios
cd example/ios && bundle exec pod install
```

## Package Baseline

Important package versions currently declared in the manifests:

| Package | Current | Registry latest from scan |
| --- | ---: | ---: |
| `react-native` | `0.85.3` | `0.85.3` |
| `react` | `19.2.3` | `19.2.7` |
| `@react-native-community/cli` | `20.1.3` | `20.1.3` |
| `@react-native/babel-preset` | `0.85.3` | `0.85.3` |
| `@react-native/metro-config` | `0.85.3` | `0.85.3` |
| `@react-native/typescript-config` | `0.85.3` | `0.85.3` |
| `@react-native/eslint-config` | `0.85.3` | `0.85.3` |
| `@react-native/jest-preset` | `0.85.3` | `0.85.3` |
| `react-native-nitro-modules` | `^0.35.9` | `0.35.9` |
| `nitrogen` | `^0.35.9` | `0.35.9` |
| `react-native-builder-bob` | `^0.39.0` | `0.41.0` |
| `typescript` | `^5.2.2` | `6.0.3` |
| `eslint` | `^9.22.0` | `10.4.1` |
| `jest` | `^29.7.0` | `30.4.2` |
| `turbo` | `^1.10.7` | `2.9.16` |
| `axios` | `^1.8.4` | `1.17.0` |

React Native 0.85 requires Node `^20.19.4 || ^22.13.0 || ^24.3.0 || >= 25.0.0`, so the repo now pins `v20.19.4`. React is intentionally pinned to `19.2.3` because React Native 0.85.3 embeds `react-native-renderer@19.2.3` and enforces an exact runtime version match.

## Modernization Plan

1. The JavaScript React Native family is now updated to the latest compatible versions from this scan: `react-native`, `@react-native/*`, and `@react-native-community/cli*` are on the latest registry versions, while `react` is pinned to the renderer-compatible `19.2.3`.
2. The example native projects have been aligned with the React Native 0.85.3 template where applicable, including Android SDK/Kotlin/Gradle pins, Android `MainApplication`, iOS `AppDelegate`, and the iOS pod lockfile.
3. The React Native package migration is validated by `typecheck`, `lint`, `test`, `example react-native config`, `example build:android`, and `example build:ios`.
4. Nitro runtime and Nitrogen codegen are now updated to the latest registry versions from this scan. Regenerate bindings with `yarn nitrogen` after any future spec or Nitro dependency change.
5. Upgrade library tooling after the native stack builds: Bob, TypeScript, ESLint, Jest, release tooling, and Turbo.

## Known Gaps

- `src/__tests__/index.test.tsx` only contains `it.todo('write a test')`.
- README and example docs now describe network monitoring as implemented, but there are no tests around the wrappers.
- GitHub credentials are configured directly in `example/config.ts`; a safer `.env` flow would be better for future example work.
- Android screenshot attachment remains missing.
- Native crash reporting behavior should be verified after the package upgrade because React Native error and lifecycle internals can change across versions.
