#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Объявляем класс заранее, чтобы компилятор не ругался
// Объявляем класс заранее, чтобы компилятор не ругался
@interface AllAppsViewController : UIViewController
@property (nonatomic, strong) NSArray *apps;
@end

// ================= ГЛАВНЫЙ ЭКРАН =================
@interface MainMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *listApps;
@property (nonatomic, strong) NSMutableArray *gridApps;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *sl = [defs objectForKey:@"SL"]; NSArray *sg = [defs objectForKey:@"SG"];
    self.listApps = sl ? [sl mutableCopy] : [@[@{@"name": @"Sileo", @"url": @"sileo://"}, @{@"name": @"Filza", @"url": @"filza://"}, @{@"name": @"Настройки", @"url": @"App-Prefs://"}, @{@"name": @"Файлы", @"url": @"shareddocuments://"}] mutableCopy];
    self.gridApps = sg ? [sg mutableCopy] : [@[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]] mutableCopy];
    [self setupUI];
}

- (void)setupUI {
    for (UIView *v in self.view.subviews) { [v removeFromSuperview]; }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 300, 40)];
    title.text = @"Freedom OS"; title.textColor = [UIColor whiteColor]; title.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:title];

    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    addBtn.frame = CGRectMake(self.view.bounds.size.width/2 - 60, 50, 40, 40);
    [addBtn setTitle:@"+" forState:UIControlStateNormal]; [addBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; addBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [addBtn addTarget:self action:@selector(addListApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];

    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 120 + (i * 50), self.view.bounds.size.width/2 - 30, 40);
        [btn setTitle:app[@"name"] forState:UIControlStateNormal]; [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; btn.titleLabel.font = [UIFont systemFontOfSize:20]; btn.tag = i;
        [btn addTarget:self action:@selector(openListApp:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteListApp:)];
        [btn addGestureRecognizer:lp]; [self.view addSubview:btn];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, btn.frame.size.width, 1)]; line.backgroundColor = [UIColor darkGrayColor]; [btn addSubview:line];
    }

    for (int i = 0; i < 6; i++) {
        id appData = self.gridApps[i];
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        int col = i % 2; int row = i / 2;
        tile.frame = CGRectMake(self.view.bounds.size.width/2 + 10 + (col * 80), 120 + (row * 80), 70, 70);
        tile.layer.cornerRadius = 15; tile.tag = i;
        if (appData == [NSNull null] || !appData) {
            tile.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0]; [tile setTitle:@"+" forState:UIControlStateNormal]; [tile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; tile.titleLabel.font = [UIFont systemFontOfSize:30];
            [tile addTarget:self action:@selector(addTile:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            tile.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0]; [tile setTitle:appData[@"name"] forState:UIControlStateNormal]; [tile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; tile.titleLabel.font = [UIFont boldSystemFontOfSize:11]; tile.titleLabel.numberOfLines = 2; tile.titleLabel.textAlignment = NSTextAlignmentCenter;
            [tile addTarget:self action:@selector(openTile:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTile:)];
            [tile addGestureRecognizer:lp];
        }
        [self.view addSubview:tile];
    }

    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    NSData *dataLeft = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"]];
    [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal]; peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    NSData *dataRight = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/thumb/8/87/Peter_Griffin_Toilet.png/220px-Peter_Griffin_Toilet.png"]];
    [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal]; peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterRight addTarget:self action:@selector(openFirefox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];
}

- (void)openFirefox { [self openURL:@"firefox://"]; }
- (void)goToAllApps {
    AllAppsViewController *vc = [[AllAppsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addListApp {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Новое" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        NSString *n = a.textFields[0].text; NSString *u = a.textFields[1].text;
        if (n.length > 0 && u.length > 0) { [self.listApps addObject:@{@"name": n, @"url": u}]; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)deleteListApp:(UILongPressGestureRecognizer *)g {
    if (g.state != UIGestureRecognizerStateBegan) return;
    [self.listApps removeObjectAtIndex:((UIButton *)g.view).tag]; [self saveAll];
}

- (void)addTile:(UIButton *)sender {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Плитка" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        NSString *n = a.textFields[0].text; NSString *u = a.textFields[1].text;
        if (n.length > 0 && u.length > 0) { self.gridApps[sender.tag] = @{@"name": n, @"url": u}; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)openTile:(UIButton *)sender { [self openURL:self.gridApps[sender.tag][@"url"]]; }
- (void)deleteTile:(UILongPressGestureRecognizer *)g { if (g.state != UIGestureRecognizerStateBegan) return; self.gridApps[((UIButton *)g.view).tag] = [NSNull null]; [self saveAll]; }
- (void)openListApp:(UIButton *)sender { [self openURL:self.listApps[sender.tag][@"url"]]; }

- (void)openURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) { [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil]; }
}

- (void)saveAll {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:self.listApps forKey:@"SL"]; [d setObject:self.gridApps forKey:@"SG"]; [d synchronize]; [self setupUI];
}
@end

// ================= ЭКРАН ВСЕХ ПРИЛОЖЕНИЙ =================
@interface AllAppsViewController : UIViewController
@property (nonatomic, strong) NSArray *apps;
@end

@implementation AllAppsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor]; self.title = @"Все приложения";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds]; [self.view addSubview:sv];

    NSMutableArray *arr = [NSMutableArray array];
    Class wsC = objc_getClass("LSApplicationWorkspace"); NSObject *ws = [wsC performSelector:@selector(defaultWorkspace)];
    
    // Защита от краша, если API вернет nil
    NSArray *installed = [ws performSelector:@selector(allInstalledApplications)];
    if (installed) {
        for (NSDictionary *info in installed) {
            NSString *n = info[@"CFBundleDisplayName"] ?: info[@"CFBundleName"]; NSString *b = info[@"CFBundleIdentifier"];
            if (n && b && ![n isEqualToString:@"Freedom OS"]) { [arr addObject:@{@"name": n, @"bundleID": b}]; }
        }
    }
    self.apps = [arr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *o1, NSDictionary *o2) { return [o1[@"name"] localizedCaseInsensitiveCompare:o2[@"name"]]; }];

    int cols = 4; CGFloat sp = 20.0; CGFloat w = (self.view.bounds.size.width - (sp * (cols + 1))) / cols; CGFloat h = w + 20;
    for (int i = 0; i < self.apps.count; i++) {
        int c = i % cols; int r = i / cols;
        UIView *cont = [[UIView alloc] initWithFrame:CGRectMake(sp + (c * (w + sp)), 20 + (r * (h + sp)), w, h)];
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom]; b.frame = CGRectMake(0, 0, w, w); b.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0]; b.layer.cornerRadius = 15;
        
        UIImage *ic = [UIImage _applicationIconImageForBundleIdentifier:self.apps[i][@"bundleID"] format:0 scale:[UIScreen mainScreen].scale];
        if (ic) { [b setImage:ic forState:UIControlStateNormal]; b.imageView.contentMode = UIViewContentModeScaleAspectFit; b.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10); b.backgroundColor = [UIColor clearColor]; }
        
        [b addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside]; b.tag = i; [cont addSubview:b];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, w + 2, w, 20)]; l.text = self.apps[i][@"name"]; l.textColor = [UIColor whiteColor]; l.font = [UIFont systemFontOfSize:12]; l.textAlignment = NSTextAlignmentCenter; [cont addSubview:l];
        [sv addSubview:cont];
    }
    sv.contentSize = CGSizeMake(self.view.bounds.size.width, (self.apps.count / cols + 1) * (h + sp) + 50);
}
- (void)openApp:(UIButton *)sender {
    Class wsC = objc_getClass("LSApplicationWorkspace"); NSObject *ws = [wsC performSelector:@selector(defaultWorkspace)];
    [ws performSelector:@selector(openApplicationWithBundleID:) withObject:self.apps[sender.tag][@"bundleID"]];
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
