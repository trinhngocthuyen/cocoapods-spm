import DebugKitObjC
import NetworkInterceptor
import NetworkLogger

public struct DebugKit {
  init() {
    print(NetworkLogger.self)
    print(NetworkInterceptor.self)
    diagnose()
  }
}
