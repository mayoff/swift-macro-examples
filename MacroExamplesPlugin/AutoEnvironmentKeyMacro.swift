import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum AutoEnvironmentKeyMacro {
  private static func keyName(for identifier: TokenSyntax) -> String {
    // I'd like to do this:
    //
    // let keyName = context.createUniqueName("EnvironmentKey_for_\(identifier.trimmedDescription)")
    //
    // But I need the same name in my PeerMacro conformance, and I don't have a way to communicate the generated name between the calls.

    return "EnvironmentKey_for_\(identifier.trimmedDescription)"
  }
}

extension AutoEnvironmentKeyMacro: AccessorMacro {
  public static func expansion<
    Context: MacroExpansionContext,
    Declaration: DeclSyntaxProtocol
  >(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: Declaration,
    in context: Context
  ) throws -> [AccessorDeclSyntax] {
    guard
      let varDecl = declaration.as(VariableDeclSyntax.self),
      varDecl.bindings.count == 1,
      let binding = varDecl.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
      binding.accessor == nil
    else { throw CustomError.message("Something is amiss.") }

    let keyName = Self.keyName(for: identifier)

    return [
      "\n    get { self[\(raw: keyName).self] }\n",
      "\n    set { self[\(raw: keyName).self] = newValue }\n\n"
    ]
  }
}

#if false
extension AutoEnvironmentKeyMacro: PeerMacro {
  public static func expansion<
    Context: MacroExpansionContext,
    Declaration: DeclSyntaxProtocol
  >(
    of node: AttributeSyntax,
    providingPeersOf declaration: Declaration,
    in context: Context
  ) throws -> [DeclSyntax] {
    guard
      let varDecl = declaration.as(VariableDeclSyntax.self),
      varDecl.bindings.count == 1,
      let binding = varDecl.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
      let type = binding.typeAnnotation?.type,
      let initializer = binding.initializer?.value,
      binding.accessor == nil
    else { throw CustomError.message("Something is amiss.") }

    let keyName = Self.keyName(for: identifier)

    return [
      """

        private enum \(raw: keyName): EnvironmentKey {
          static var defaultValue: \(type.trimmed) { \(initializer) }
        }
      """
    ]
  }
}
#endif
