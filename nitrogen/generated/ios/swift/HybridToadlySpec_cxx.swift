///
/// HybridToadlySpec_cxx.swift
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2025 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/**
 * A class implementation that bridges HybridToadlySpec over to C++.
 * In C++, we cannot use Swift protocols - so we need to wrap it in a class to make it strongly defined.
 *
 * Also, some Swift types need to be bridged with special handling:
 * - Enums need to be wrapped in Structs, otherwise they cannot be accessed bi-directionally (Swift bug: https://github.com/swiftlang/swift/issues/75330)
 * - Other HybridObjects need to be wrapped/unwrapped from the Swift TCxx wrapper
 * - Throwing methods need to be wrapped with a Result<T, Error> type, as exceptions cannot be propagated to C++
 */
public class HybridToadlySpec_cxx {
  /**
   * The Swift <> C++ bridge's namespace (`margelo::nitro::toadly::bridge::swift`)
   * from `Toadly-Swift-Cxx-Bridge.hpp`.
   * This contains specialized C++ templates, and C++ helper functions that can be accessed from Swift.
   */
  public typealias bridge = margelo.nitro.toadly.bridge.swift

  /**
   * Holds an instance of the `HybridToadlySpec` Swift protocol.
   */
  private var __implementation: any HybridToadlySpec

  /**
   * Holds a weak pointer to the C++ class that wraps the Swift class.
   */
  private var __cxxPart: bridge.std__weak_ptr_margelo__nitro__toadly__HybridToadlySpec_

  /**
   * Create a new `HybridToadlySpec_cxx` that wraps the given `HybridToadlySpec`.
   * All properties and methods bridge to C++ types.
   */
  public init(_ implementation: any HybridToadlySpec) {
    self.__implementation = implementation
    self.__cxxPart = .init()
    /* no base class */
  }

  /**
   * Get the actual `HybridToadlySpec` instance this class wraps.
   */
  @inline(__always)
  public func getHybridToadlySpec() -> any HybridToadlySpec {
    return __implementation
  }

  /**
   * Casts this instance to a retained unsafe raw pointer.
   * This acquires one additional strong reference on the object!
   */
  public func toUnsafe() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(self).toOpaque()
  }

  /**
   * Casts an unsafe pointer to a `HybridToadlySpec_cxx`.
   * The pointer has to be a retained opaque `Unmanaged<HybridToadlySpec_cxx>`.
   * This removes one strong reference from the object!
   */
  public class func fromUnsafe(_ pointer: UnsafeMutableRawPointer) -> HybridToadlySpec_cxx {
    return Unmanaged<HybridToadlySpec_cxx>.fromOpaque(pointer).takeRetainedValue()
  }

  /**
   * Gets (or creates) the C++ part of this Hybrid Object.
   * The C++ part is a `std::shared_ptr<margelo::nitro::toadly::HybridToadlySpec>`.
   */
  public func getCxxPart() -> bridge.std__shared_ptr_margelo__nitro__toadly__HybridToadlySpec_ {
    let cachedCxxPart = self.__cxxPart.lock()
    if cachedCxxPart.__convertToBool() {
      return cachedCxxPart
    } else {
      let newCxxPart = bridge.create_std__shared_ptr_margelo__nitro__toadly__HybridToadlySpec_(self.toUnsafe())
      __cxxPart = bridge.weakify_std__shared_ptr_margelo__nitro__toadly__HybridToadlySpec_(newCxxPart)
      return newCxxPart
    }
  }

  

  /**
   * Get the memory size of the Swift class (plus size of any other allocations)
   * so the JS VM can properly track it and garbage-collect the JS object if needed.
   */
  @inline(__always)
  public var memorySize: Int {
    return MemoryHelper.getSizeOf(self.__implementation) + self.__implementation.memorySize
  }

  // Properties
  

  // Methods
  @inline(__always)
  public final func setup(githubToken: std.string, repoOwner: std.string, repoName: std.string) -> bridge.Result_void_ {
    do {
      try self.__implementation.setup(githubToken: String(githubToken), repoOwner: String(repoOwner), repoName: String(repoName))
      return bridge.create_Result_void_()
    } catch (let __error) {
      let __exceptionPtr = __error.toCpp()
      return bridge.create_Result_void_(__exceptionPtr)
    }
  }
  
  @inline(__always)
  public final func addJSLogs(logs: std.string) -> bridge.Result_void_ {
    do {
      try self.__implementation.addJSLogs(logs: String(logs))
      return bridge.create_Result_void_()
    } catch (let __error) {
      let __exceptionPtr = __error.toCpp()
      return bridge.create_Result_void_(__exceptionPtr)
    }
  }
  
  @inline(__always)
  public final func show() -> bridge.Result_void_ {
    do {
      try self.__implementation.show()
      return bridge.create_Result_void_()
    } catch (let __error) {
      let __exceptionPtr = __error.toCpp()
      return bridge.create_Result_void_(__exceptionPtr)
    }
  }
  
  @inline(__always)
  public final func createIssueWithTitle(title: std.string, reportType: bridge.std__optional_std__string_) -> bridge.Result_void_ {
    do {
      try self.__implementation.createIssueWithTitle(title: String(title), reportType: { () -> String? in
        if let __unwrapped = reportType.value {
          return String(__unwrapped)
        } else {
          return nil
        }
      }())
      return bridge.create_Result_void_()
    } catch (let __error) {
      let __exceptionPtr = __error.toCpp()
      return bridge.create_Result_void_(__exceptionPtr)
    }
  }
  
  @inline(__always)
  public final func crashNative() -> bridge.Result_void_ {
    do {
      try self.__implementation.crashNative()
      return bridge.create_Result_void_()
    } catch (let __error) {
      let __exceptionPtr = __error.toCpp()
      return bridge.create_Result_void_(__exceptionPtr)
    }
  }
}
