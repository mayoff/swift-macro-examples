import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MacroExamplesPlugin
import XCTest

final class AutoEnvironmentKeyPluginTests: XCTestCase {
  let testMacros: [String: Macro.Type] = [
    "AutoEnvironmentKey": AutoEnvironmentKeyMacro.self
  ]

  func testAutoEnvironmentKey() {
    let sf: SourceFileSyntax =
      #"""
      extension EnvironmentValues {
        @AutoEnvironmentKey
        public var myValue: String = "don't abuse macros"
      }
      """#

    let context = BasicMacroExpansionContext(
      sourceFiles: [sf: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
    )

    let transformed = sf.expand(macros: testMacros, in: context)

    let expected: SourceFileSyntax =
      #"""
      extension EnvironmentValues {
        public var myValue: String {
          get { self[EnvironmentKey_for_myValue.self] }
          set { self[EnvironmentKey_for_myValue.self] = newValue }
      }
        private enum EnvironmentKey_for_myValue: EnvironmentKey {
          static var defaultValue: String { "don't abuse macros" }
        }
      }
      """#

    XCTAssertEqual(
      transformed.description,
      expected.description
    )
  }
}
