import UIKit

@freestanding(expression)
public macro uiColor(_ intLiteral: IntegerLiteralType ) -> UIColor = #externalMacro(module: "WizardImpl", type: "HexToUIColorMacro")
