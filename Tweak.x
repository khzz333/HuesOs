#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

@interface SBHomeButtonController : NSObject
- (void)handleButtonDown:(long long)event;
@end

%hook SBHomeButtonController

- (void)handleButtonDown:(long long)event {
    if (event == 1) {
        Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
        NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
        [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.bebra.freedomos"];
        return; 
    }
    %orig;
}

%end
