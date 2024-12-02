import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct HexColorMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    HexToUIColorMacro.self,
  ]
}
