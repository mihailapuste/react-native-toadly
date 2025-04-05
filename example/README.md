# Toadly Example App

This example app demonstrates the basic features of the Toadly SDK for React Native, showing how to integrate bug reporting and logging into your React Native application.

## Features Demonstrated

### 1. Bug Reporting
- Manually trigger the bug reporting dialog
- Include logs and device information in reports
- Automatically create GitHub issues

### 2. Custom Logging
- Add custom log entries for business logic
- Clear logs when needed

## Getting Started

### Prerequisites

Before running the example app, make sure you have:

1. A GitHub account with a personal access token
2. A repository where issues will be created
3. React Native development environment set up

### Configuration

1. Create a `config.ts` file in the project root with your GitHub credentials:

```typescript
export const config = {
  github: {
    token: 'YOUR_GITHUB_TOKEN',
    repoOwner: 'YOUR_GITHUB_USERNAME_OR_ORG',
    repoName: 'YOUR_REPOSITORY_NAME',
  },
};
```

### Installation

Install dependencies:

```sh
# Using yarn
yarn install

# Or using npm
npm install
```

For iOS, install CocoaPods dependencies:

```sh
cd ios && pod install && cd ..
```

### Running the App

Start the Metro bundler:

```sh
# Using yarn
yarn start

# Or using npm
npm start
```

Run on iOS:

```sh
# Using yarn
yarn ios

# Or using npm
npm run ios
```

Run on Android:

```sh
# Using yarn
yarn android

# Or using npm
npm run android
```

## App Structure

The example app demonstrates Toadly's features through a simple interface:

- **Bug Reporting**: Tap "Report a Bug" to open the bug reporting dialog
- **Log Management**: Add custom logs and clear logs with the provided buttons

## Implementation Details

### Initialization

Toadly is initialized in `App.tsx` with GitHub credentials:

```typescript
import * as Toadly from 'react-native-toadly';
import { config } from '../config';

const { token, repoOwner, repoName } = config.github;
Toadly.setup(token, repoOwner, repoName);
```

### Custom Logging

Add custom logs to provide context for bug reports:

```typescript
// Add a custom log
Toadly.log('User performed an action');
```

## Troubleshooting

If you encounter issues:

1. Make sure your GitHub token has the necessary permissions
2. Verify that the repository exists and you have write access
3. Check that all dependencies are properly installed
4. For iOS-specific issues, try cleaning the build folder and reinstalling pods

## Learn More

For more information about Toadly, check out the [main README](../README.md) and the [API documentation](../README.md#api-reference).
