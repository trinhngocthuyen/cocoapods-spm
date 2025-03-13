public struct NetworkLogger {
  public init() { }
  public func log(_ message: @autoclosure () -> String) {
    print(message())
  }
}
