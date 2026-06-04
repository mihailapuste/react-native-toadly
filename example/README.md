# Toadly Example App

This example app demonstrates the Toadly SDK for React Native. It uses the local workspace copy of `react-native-toadly`, so changes to the SDK package can be tested here without publishing.

## Features Demonstrated

### 1. Bug Reporting
- Manually trigger the bug reporting dialog
- Include logs and device information in reports
- Automatically create GitHub issues

### 2. Custom Logging
- Add custom log entries for business logic
- Clear logs when needed

### 3. Crash and Network Reporting
- Enable automatic JavaScript fatal error issue submission
- Trigger a native crash for testing
- Capture successful and failed API calls through network monitoring

## Getting Started

### Prerequisites

Before running the example app, make sure you have:

1. A GitHub account with a personal access token
2. A repository where issues will be created
3. React Native development environment set up for iOS or Android
4. Node matching the repository `.nvmrc`

### Configuration

Create `example/config.ts` from the checked-in template:

```sh
cp example/config.example.ts example/config.ts
```

Then fill in your GitHub credentials:

```typescript
export const config = {
  github: {
    token: 'YOUR_GITHUB_TOKEN',
    repoOwner: 'YOUR_GITHUB_USERNAME_OR_ORG',
    repoName: 'YOUR_REPOSITORY_NAME',
  },
};
```

Do not commit a real GitHub token.

### Installation

Install dependencies from the repository root:

```sh
yarn install
```

This project uses Yarn workspaces. If `yarn` is not available globally, run the pinned Yarn release directly from the repository root:

```sh
node .yarn/releases/yarn-3.6.1.cjs install
```

For iOS, install CocoaPods dependencies:

```sh
cd example/ios
pod install
cd ../..
```

### Running the App

Run commands from the repository root.

Start Metro:

```sh
yarn example start
```

Run on iOS:

```sh
yarn example ios
```

Run on Android:

```sh
yarn example android
```

## App Structure

The example app demonstrates Toadly's features through a simple interface:

- **Bug Reporting**: Tap "Report a Bug" to open the bug reporting dialog
- **Log Management**: Add custom logs and clear logs with the provided buttons
- **Crash Testing**: Trigger caught, fatal JavaScript, and native errors
- **API Testing**: Make successful and failed API calls for network logs

## Implementation Details

### Initialization

Toadly is initialized in `App.tsx` with GitHub credentials:

```typescript
import * as Toadly from 'react-native-toadly';
import { config } from '../config';

const { token, repoOwner, repoName } = config.github;
Toadly.setup(token, repoOwner, repoName);
Toadly.enableAutomaticIssueSubmission(true);
Toadly.startNetworkMonitoring();
```

### Custom Logging

Add custom logs to provide context for bug reports:

```typescript
// Add a custom log
Toadly.log('User performed an action');
```

## Troubleshooting

If you encounter issues:

1. Make sure your GitHub token can create issues in the target repository.
2. Verify that `example/config.ts` exists and matches the shape of `example/config.example.ts`.
3. Run commands from the repository root so the workspace dependency links resolve correctly.
4. If `yarn` is missing, use `node .yarn/releases/yarn-3.6.1.cjs <command>`.
5. For iOS-specific issues, clean the build folder and reinstall pods in `example/ios`.
6. If native code or Nitro specs changed, run `yarn nitrogen` before rebuilding.

## Learn More

For more information about Toadly, check out the [main README](../README.md) and the [API documentation](../README.md#api).
