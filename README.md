# Toadly

<p align="center">
  <img src="https://github.com/user-attachments/assets/52d29b6b-c638-4963-bc1b-ac62bf5ee820" alt="Screenshot" height="180">
</p>

Toadly is an early-stage bug reporting SDK for React Native apps. It uses Nitro Modules to bridge JavaScript with native iOS and Android code, collects recent logs, and submits reports to GitHub issues.

## Features

- In-app bug report dialog for user-submitted issues.
- GitHub issue creation from manual reports and automatic crash reports.
- JavaScript console capture for `console.log`, `console.info`, `console.warn`, and `console.error`.
- Native log capture on iOS and Android.
- Automatic JavaScript fatal error reporting when enabled.
- Network request logging for `fetch` and `XMLHttpRequest`.
- Screenshot attachment for iOS manual reports.

## Current Limitations

- Android screenshot attachment is not implemented yet.
- The public API is intentionally small and may still change before a stable release.
- The example app stores GitHub credentials in a local `example/config.ts`; do not commit real tokens.

## Installation

```sh
npm install react-native-toadly react-native-nitro-modules

# or with yarn
yarn add react-native-toadly react-native-nitro-modules
```

For iOS apps, install pods after adding the package:

```sh
cd ios
pod install
cd ..
```

## Basic Usage

```tsx
import { useEffect } from 'react';
import { Button } from 'react-native';
import * as Toadly from 'react-native-toadly';

Toadly.setup('GITHUB_TOKEN', 'repo-owner', 'repo-name');
Toadly.enableAutomaticIssueSubmission(true);
Toadly.startNetworkMonitoring();

export function App() {
  useEffect(() => {
    Toadly.log('App mounted');

    return () => {
      Toadly.log('App unmounted');
    };
  }, []);

  return <Button title="Report a bug" onPress={() => Toadly.show()} />;
}
```

## API

| Function | Description |
| --- | --- |
| `setup(githubToken, repoOwner, repoName)` | Configures GitHub issue submission. Call this once before showing the reporter or auto-submitting issues. |
| `show()` | Opens the native bug report UI and attaches recent JS logs. |
| `log(message)` | Adds a custom Toadly log entry. Console methods are captured automatically after the module is imported. |
| `clearLogs()` | Clears collected JavaScript logs. |
| `enableAutomaticIssueSubmission(enable = true)` | Enables or disables GitHub issue creation for fatal JavaScript errors. |
| `startNetworkMonitoring()` | Starts capturing `fetch` and `XMLHttpRequest` activity. |
| `stopNetworkMonitoring()` | Stops network capture and restores the original request implementations. |
| `isNetworkMonitoringActive()` | Returns whether network capture is active. |
| `clearNetworkHistory()` | Clears captured network request history. |
| `crashNative()` | Intentionally crashes the native app for crash-report testing. |

## Example App

The [example app](./example) exercises manual reports, log capture, automatic JavaScript crash submission, native crash testing, and network logging. Start there when validating changes to the SDK.

## Development

This repository is a Yarn workspace with the SDK in the root package and the example app in `example/`. See [CONTRIBUTING.md](./CONTRIBUTING.md) for local setup and [docs/resume.md](./docs/resume.md) for the current project scan, package modernization notes, and known follow-up work.

## License

MIT
