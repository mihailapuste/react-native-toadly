#include <jni.h>
#include "toadlyOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return margelo::nitro::toadly::initialize(vm);
}
