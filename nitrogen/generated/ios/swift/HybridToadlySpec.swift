///
/// HybridToadlySpec.swift
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2025 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/// See ``HybridToadlySpec``
public protocol HybridToadlySpec_protocol: HybridObject {
  // Properties
  

  // Methods
  func setup(githubToken: String, repoOwner: String, repoName: String) throws -> Void
  func addJSLogs(logs: String) throws -> Void
  func show() throws -> Void
  func createIssueWithTitle(title: String, reportType: String?) throws -> Void
  func crashNative() throws -> Void
}

/// See ``HybridToadlySpec``
public class HybridToadlySpec_base {
  private weak var cxxWrapper: HybridToadlySpec_cxx? = nil
  public func getCxxWrapper() -> HybridToadlySpec_cxx {
  #if DEBUG
    guard self is HybridToadlySpec else {
      fatalError("`self` is not a `HybridToadlySpec`! Did you accidentally inherit from `HybridToadlySpec_base` instead of `HybridToadlySpec`?")
    }
  #endif
    if let cxxWrapper = self.cxxWrapper {
      return cxxWrapper
    } else {
      let cxxWrapper = HybridToadlySpec_cxx(self as! HybridToadlySpec)
      self.cxxWrapper = cxxWrapper
      return cxxWrapper
    }
  }
}

/**
 * A Swift base-protocol representing the Toadly HybridObject.
 * Implement this protocol to create Swift-based instances of Toadly.
 * ```swift
 * class HybridToadly : HybridToadlySpec {
 *   // ...
 * }
 * ```
 */
public typealias HybridToadlySpec = HybridToadlySpec_protocol & HybridToadlySpec_base
