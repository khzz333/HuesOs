#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *listApps;
@property (nonatomic, strong) NSMutableArray *gridApps;
@property (nonatomic, strong) UIView *gridContainer;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedList = [defaults objectForKey:@"SavedList"];
    NSArray *savedGrid = [defaults objectForKey:@"SavedGrid"];
    
    self.listApps = savedList ? [savedList mutableCopy] : [@[
        @{@"name": @"Sileo", @"url": @"sileo://"},
        @{@"name": @"Filza", @"url": @"filza://"},
        @{@"name": @"Настройки", @"url": @"App-Prefs://"},
        @{@"name": @"Файлы", @"url": @"shareddocuments://"}
    ] mutableCopy];
    
    self.gridApps = savedGrid ? [savedGrid mutableCopy] : [@[
        [NSNull null], [NSNull null], [NSNull null], 
        [NSNull null], [NSNull null], [NSNull null]
    ] mutableCopy];

    [self setupUI];
}

- (void)setupUI {
    for (UIView *view in self.view.subviews) { [view removeFromSuperview]; }

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 300, 40)];
    titleLabel.text = @"Freedom OS";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:titleLabel];

    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 120 + (i * 60), self.view.bounds.size.width / 2 - 30, 50);
        [btn setTitle:app[@"name"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
        btn.tag = i;
        [btn addTarget:self action:@selector(openListApp:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editListApp:)];
        [btn addGestureRecognizer:lp];
        [self.view addSubview:btn];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, btn.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [btn addSubview:line];
    }

    self.gridContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 + 10, 120, self.view.bounds.size.width / 2 - 20, 300)];
    [self.view addSubview:self.gridContainer];

    for (int i = 0; i < 6; i++) {
        id appData = self.gridApps[i];
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        
        int col = i % 2;
        int row = i / 2;
        tile.frame = CGRectMake(col * 80, row * 80, 70, 70);
        
        tile.layer.cornerRadius = 15;
        tile.tag = i;
        
        if (appData == [NSNull null] || !appData) {
            tile.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
            [tile setTitle:@"+" forState:UIControlStateNormal];
            [tile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tile.titleLabel.font = [UIFont systemFontOfSize:30];
            [tile addTarget:self action:@selector(addTile:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            tile.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
            [tile setTitle:appData[@"name"] forState:UIControlStateNormal];
            [tile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            tile.titleLabel.font = [UIFont boldSystemFontOfSize:11];
            tile.titleLabel.numberOfLines = 2;
            tile.titleLabel.textAlignment = NSTextAlignmentCenter;
            [tile addTarget:self action:@selector(openTile:) forControlEvents:UIControlEventTouchUpInside];
            
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTile:)];
            [tile addGestureRecognizer:lp];
        }
        [self.gridContainer addSubview:tile];
    }

    // ================= ПИТЕРЫ ВНИЗУ =================
    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    NSURL *urlLeft = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"];
    NSData *dataLeft = [NSData dataWithContentsOfURL:urlLeft];
    [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal];
    peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    NSURL *urlRight = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/5/5b/Retep_Griffin.png"];
    NSData *dataRight = [NSData dataWithContentsOfURL:urlRight];
    [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal];
    peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterRight addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];
}

// ================= ДЕЙСТВИЯ =================
- (void)goToAllApps {
    UIViewController *allAppsVC = [[UIViewController alloc] init];
    allAppsVC.view.backgroundColor = [UIColor darkGrayColor];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    lbl.center = allAppsVC.view.center;
    lbl.text = @"Тут будет сетка всех приложений";
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [allAppsVC.view addSubview:lbl];

    [self presentViewController:allAppsVC animated:YES completion:nil];
}

- (void)openSafari {
    [self openURL:@"https://google.com"];
}

- (void)addTile:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Новая плитка" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull tf) { tf.placeholder = @"Название"; }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull tf) { tf.placeholder = @"Ссылка (youtube://)"; }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields[0].text;
        NSString *url = alert.textFields[1].text;
        if (name.length > 0 && url.length > 0) {
            self.gridApps[sender.tag] = @{@"name": name, @"url": url};
            [self saveAll];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openTile:(UIButton *)sender {
    NSDictionary *app = self.gridApps[sender.tag];
    [self openURL:app[@"url"]];
}

- (void)deleteTile:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    UIButton *btn = (UIButton *)gesture.view;
    self.gridApps[btn.tag] = [NSNull null];
    [self saveAll];
}

- (void)openListApp:(UIButton *)sender {
    NSDictionary *app = self.listApps[sender.tag];
    [self openURL:app[@"url"]];
}

- (void)editListApp:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
}

- (void)openURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)saveAll {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.listApps forKey:@"SavedList"];
    [defaults setObject:self.gridApps forKey:@"SavedGrid"];
    [defaults synchronize];
    [self setupUI];
}
@end

// ================= ЗАПУСК =================
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[MainMenuViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
