package com.margelo.nitro.toadly
  
import com.facebook.proguard.annotations.DoNotStrip

@DoNotStrip
class Toadly : HybridToadlySpec() {
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }
}
