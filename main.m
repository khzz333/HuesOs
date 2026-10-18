#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@interface MenuViewController : UIViewController
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[MenuViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end

@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 300, 40)];
    title.text = @"Freedom OS";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:title];

    NSArray *apps = @[@"Sileo", @"Filza", @"Настройки", @"Файлы"];
    NSArray *urls = @[@"sileo://", @"filza://", @"App-Prefs://", @"shareddocuments://"];

    for (int i = 0; i < apps.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 120 + (i * 60), 350, 50);
        [btn setTitle:apps[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        btn.tag = i;
        [btn addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, 350, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [btn addSubview:line];
    }
}

- (void)openApp:(UIButton *)sender {
    NSArray *urls = @[@"sileo://", @"filza://", @"App-Prefs://", @"shareddocuments://"];
    NSURL *url = [NSURL URLWithString:urls[sender.tag]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
