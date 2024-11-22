import DebugKitObjC
import NetworkInterceptor
import NetworkLogger

@objc public class DebugKit: NSObject {
  override init() {
    print(NetworkLogger.self)
    print(NetworkInterceptor.self)
    diagnose()
  }
}
