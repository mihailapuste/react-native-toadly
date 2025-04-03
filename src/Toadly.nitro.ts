import type { HybridObject } from 'react-native-nitro-modules';

export interface Toadly
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  /**
   * Shows a bug reporting dialog
   */
  show(): void;

  /**
   * Setup the module with GitHub configuration
   * @param githubToken GitHub access token
   * @param repoOwner Repository owner (username or organization)
   * @param repoName Repository name
   */
  setup(githubToken: string, repoOwner: string, repoName: string): void;
}
