
/// I turn this syntax:
///
/// ```
/// extension EnvironmentValues {
///   @AutoEnvironmentKey
///   public var myValue: String = "don't abuse macros"
/// }
/// ```
///
/// into this syntax:
///
/// ```
/// extension EnvironmentValues {
///   public var myValue: String {
///     get { self[__generated_name__0xc0deface.self] }
///     set { self[__generated_name__0xc0deface.self] = newValue }
///   }
///
///   private enum __generated_name__0xc0deface: EnvironmentKey {
///     static var defaultValue: String { "don't abuse macros" }
///   }
/// }
/// ```

@attached(accessor)
@attached(peer, names: prefixed(EnvironmentKey_for_))
public macro AutoEnvironmentKey() = #externalMacro(module: "MacroExamplesPlugin", type: "AutoEnvironmentKeyMacro")
