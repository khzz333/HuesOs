#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

// Подключаем приватные классы SpringBoard для управления системой
@interface SBHomeButtonController : NSObject
- (void)handleButtonDown:(long long)event;
@end

%hook SBHomeButtonController

- (void)handleButtonDown:(long long)event {
    // event 1 = одинарное нажатие
