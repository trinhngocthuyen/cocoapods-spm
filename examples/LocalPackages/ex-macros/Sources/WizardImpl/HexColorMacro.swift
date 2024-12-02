import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MacroToolkit

enum HexMacroError: Error {
  case notFoundHex
}

public struct HexToUIColorMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let arg = node.argumentList.first, let hex = Expr(arg.expression).asIntegerLiteral?.value else {
      throw HexMacroError.notFoundHex
    }
    return """
    UIColor(
      red: CGFloat((\(raw: hex) >> 16) & 0xff) / 255,
      green: CGFloat((\(raw: hex) >> 8) & 0xff) / 255,
      blue: CGFloat((\(raw: hex) >> 0) & 0xff) / 255,
      alpha: CGFloat(1)
    )
    """
  }
}
