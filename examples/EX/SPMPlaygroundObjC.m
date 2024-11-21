@import DebugKit;
@import GoogleMaps;

@interface FooObjC: NSObject
@end

@implementation FooObjC
-(void)check {
  // Should be able to use SPM packages in ObjC
  NSLog(@"DebugKit: %@", DebugKit.description); // DebugKit
  NSLog(@"GMSAddress: %@", GMSAddress.description); // GoogleMaps
}
@end
