import { NitroModules } from 'react-native-nitro-modules';
import type { Toadly } from './Toadly.nitro';

const ToadlyHybridObject =
  NitroModules.createHybridObject<Toadly>('Toadly');

export function multiply(a: number, b: number): number {
  return ToadlyHybridObject.multiply(a, b);
}
