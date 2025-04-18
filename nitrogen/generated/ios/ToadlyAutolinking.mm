///
/// ToadlyAutolinking.mm
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2025 Marc Rousavy @ Margelo
///

#import <Foundation/Foundation.h>
#import <NitroModules/HybridObjectRegistry.hpp>
#import "Toadly-Swift-Cxx-Umbrella.hpp"
#import <type_traits>

#include "HybridToadlySpecSwift.hpp"

@interface ToadlyAutolinking : NSObject
@end

@implementation ToadlyAutolinking

+ (void) load {
  using namespace margelo::nitro;
  using namespace margelo::nitro::toadly;

  HybridObjectRegistry::registerHybridObjectConstructor(
    "Toadly",
    []() -> std::shared_ptr<HybridObject> {
      std::shared_ptr<margelo::nitro::toadly::HybridToadlySpec> hybridObject = Toadly::ToadlyAutolinking::createToadly();
      return hybridObject;
    }
  );
}

@end
