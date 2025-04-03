import { NitroModules } from 'react-native-nitro-modules';
import type { Toadly } from './Toadly.nitro';

const ToadlyHybridObject = NitroModules.createHybridObject<Toadly>('Toadly');

/**
 * Setup the Toadly module with GitHub configuration
 * @param githubToken GitHub access token from environment variables
 * @param repoOwner Repository owner (username or organization)
 * @param repoName Repository name
 */
export function setup(githubToken: string, repoOwner: string, repoName: string): void {
  return ToadlyHybridObject.setup(githubToken, repoOwner, repoName);
}

/**
 * Shows a bug reporting dialog
 */
export function show(): void {
  return ToadlyHybridObject.show();
}
