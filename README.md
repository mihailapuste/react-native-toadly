<p align="center">
  <img src="https://github.com/user-attachments/assets/52d29b6b-c638-4963-bc1b-ac62bf5ee820" alt="Screenshot" height="180">
</p>





## Introduction

**Toadly** is a lightweight, open-source bug reporting tool for React Native applications (work in progress)

Toadly helps React Native developers identify and fix issues faster by providing simple bug reporting, log collection, and GitHub integration. This project is currently under active development with more features coming soon.

## Features

### Bug Reporting
Simple in-app bug reporting dialog that lets users report issues directly from your app

### Log Collection
Capture js and native logs along to provide context for bug/crash reports

### Crash Reporting
Auto submit crashes along with logs, trace and session information

### GitHub Integration
Automatically create GitHub issues with detailed bug reports including logs and device info

### Coming Soon
- Network request monitoring
- Custom metadata attachment
- Screenshot annotations

## Simple Steps to Get Started

### 1. Install the Toadly package:

```sh
npm install react-native-toadly react-native-nitro-modules

# or with yarn
yarn add react-native-toadly react-native-nitro-modules
```

### 2. For iOS, install CocoaPods dependencies:

```sh
cd ios && pod install && cd ..
```

### 3. Initialize Toadly in your app:

```typescript
import React, { useEffect } from 'react';
import * as Toadly from 'react-native-toadly';
import { config } from './config';

// Initialize Toadly with your GitHub credentials
const { token, repoOwner, repoName } = config.github;
Toadly.setup(token, repoOwner, repoName);

export default function App() {
  useEffect(() => {
    // Add custom logs for better context
    Toadly.log('App initialized');
    
    return () => {
      Toadly.log('App will unmount');
    };
  }, []);

  // Show the bug reporter dialog
  const handleReportBug = () => {
    Toadly.show();
  };

  // Rest of your app code...
}
```

## API Reference

### Core Functions

- `Toadly.setup(token, repoOwner, repoName)` - Initialize Toadly with GitHub credentials
- `Toadly.show()` - Show the bug reporting dialog
- `Toadly.log(message)` - Add a custom log entry. Console logs are automatically captured
- `Toadly.clearLogs()` - Manually clear collected logs
- `Toadly.enableAutomaticIssueSubmission()` - Enable automatic issue submission for JS crashes
- `Toadly.startNetworkMonitoring()` - Start logging network requests to be included in reports
- `Toadly.stopNetworkMonitoring()` - Start logging network requests
- `Toadly.isNetworkMonitoringActive()` - Check network logging enabled status
- `Toadly.clearNetworkHistory()` - Manually clear network logs

## Example App

Check out the [example app](./example) to see Toadly in action and explore implementation details.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with ❤️ by the Toadly team
