import type { HybridObject } from 'react-native-nitro-modules';

export interface Toadly
  extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  // todo remove
  multiply(a: number, b: number): number;

  /**
   * Shows a bug reporting dialog
   */
  show(): void;
}
