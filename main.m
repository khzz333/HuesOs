#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ================= ГЛАВНЫЙ ЭКРАН =================
@interface MainMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *listApps;
@property (nonatomic, strong) NSMutableArray *gridApps;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedList = [defaults objectForKey:@"SavedList_v2"];
    NSArray *savedGrid = [defaults objectForKey:@"SavedGrid_v2"];
    
    // Стартовый список (если пусто)
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

    // Кнопка "+" для добавления в левый список
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    addBtn.frame = CGRectMake(self.view.bounds.size.width / 2 - 60, 50, 40, 40);
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:30];
    [addBtn addTarget:self action:@selector(addListApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];

    // ЛЕВАЯ КОЛОНКА
    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 120 + (i * 50), self.view.bounds.size.width / 2 - 30, 40);
        [btn setTitle:app[@"name"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.font = [UIFont systemFontOfSize:20];
        btn.tag = i;
        [btn addTarget:self action:@selector(openListApp:) forControlEvents:UIControlEventTouchUpInside];
        
        // Удаление по долгому нажатию
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteListApp:)];
        [btn addGestureRecognizer:lp];
        [self.view addSubview:btn];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, btn.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [btn addSubview:line];
    }

    // ПРАВАЯ КОЛОНКА (6 ПЛИТОК)
    for (int i = 0; i < 6; i++) {
        id appData = self.gridApps[i];
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        
        int col = i % 2;
        int row = i / 2;
        tile.frame = CGRectMake(self.view.bounds.size.width / 2 + 10 + (col * 80), 120 + (row * 80), 70, 70);
        
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
        [self.view addSubview:tile];
    }

    // ================= ПИТЕРЫ ВНИЗУ =================
    // Левый Питер (Открывает сетку всех приложений)
    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    NSURL *urlLeft = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"];
    NSData *dataLeft = [NSData dataWithContentsOfURL:urlLeft];
    [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal];
    peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    // Правый Питер (на унитазе, открывает Firefox)
    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    // Ссылка на Питера на унитазе
    NSURL *urlRight = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/thumb/8/87/Peter_Griffin_Toilet.png/220px-Peter_Griffin_Toilet.png"];
    NSData *dataRight = [NSData dataWithContentsOfURL:urlRight];
    [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal];
    peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterRight addTarget:self action:@selector(openFirefox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];
}

// ================= ЛОГИКА =================
- (void)openFirefox {
    [self openURL:@"firefox://"];
}

- (void)goToAllApps {
    AllAppsViewController *allAppsVC = [[AllAppsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:allAppsVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)addListApp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Новое приложение" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull tf) { tf.placeholder = @"Название"; }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull tf) { tf.placeholder = @"Ссылка (youtube://)"; }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Добавить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alert.textFields[0].text;
        NSString *url = alert.textFields[1].text;
        if (name.length > 0 && url.length > 0) {
            [self.listApps addObject:@{@"name": name, @"url": url}];
            [self saveAll];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteListApp:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    UIButton *btn = (UIButton *)gesture.view;
    [self.listApps removeObjectAtIndex:btn.tag];
    [self saveAll];
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

- (void)openURL:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ошибка" message:@"Приложение не установлено или ссылка неверная" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveAll {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.listApps forKey:@"SavedList_v2"];
    [defaults setObject:self.gridApps forKey:@"SavedGrid_v2"];
    [defaults synchronize];
    [self setupUI];
}
@end


// ================= ЭКРАН ВСЕХ ПРИЛОЖЕНИЙ (СЕТКА) =================
@interface AllAppsViewController : UIViewController
@property (nonatomic, strong) NSArray *allInstalledApps;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation AllAppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Все приложения";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 2000);
    [self.view addSubview:self.scrollView];

    [self loadInstalledApps];
    [self setupGrid];
}

- (void)loadInstalledApps {
    NSMutableArray *apps = [NSMutableArray array];
    
    // Используем приватный API LSApplicationWorkspace для получения всех приложений
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray *allApps = [workspace performSelector:@selector(allInstalledApplications)];
    
    for (NSDictionary *appInfo in allApps) {
        NSString *name = appInfo[@"CFBundleDisplayName"] ?: appInfo[@"CFBundleName"];
        NSString *bundleID = appInfo[@"CFBundleIdentifier"];
        
        if (name && bundleID && ![name isEqualToString:@"Freedom OS"]) {
            [apps addObject:@{@"name": name, @"bundleID": bundleID}];
        }
    }
    
    // Сортируем по алфавиту
    self.allInstalledApps = [apps sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"name"] localizedCaseInsensitiveCompare:obj2[@"name"]];
    }];
}

- (void)setupGrid {
    int columns = 4;
    CGFloat spacing = 20.0;
    CGFloat itemWidth = (self.view.bounds.size.width - (spacing * (columns + 1))) / columns;
    CGFloat itemHeight = itemWidth + 20; // +20 для текста

    for (int i = 0; i < self.allInstalledApps.count; i++) {
        NSDictionary *app = self.allInstalledApps[i];
        
        int col = i % columns;
        int row = i / columns;
        
        CGFloat x = spacing + (col * (itemWidth + spacing));
        CGFloat y = 20 + (row * (itemHeight + spacing));

        // Контейнер для иконки и текста
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(x, y, itemWidth, itemHeight)];
        
        // Иконка
        UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        iconBtn.frame = CGRectMake(0, 0, itemWidth, itemWidth);
        iconBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        iconBtn.layer.cornerRadius = 15;
        
        // Загружаем иконку
        UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:app[@"bundleID"] format:0 scale:[UIScreen mainScreen].scale];
        if (icon) {
            [iconBtn setImage:icon forState:UIControlStateNormal];
            iconBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            iconBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            iconBtn.backgroundColor = [UIColor clearColor];
        }
        
        [iconBtn addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside];
        iconBtn.tag = i;
        [container addSubview:iconBtn];

        // Название
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, itemWidth + 2, itemWidth, 20)];
        nameLabel.text = app[@"name"];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:12];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [container addSubview:nameLabel];

        [self.scrollView addSubview:container];
    }
    
    CGFloat totalHeight = (self.allInstalledApps.count / columns + 1) * (itemHeight + spacing) + 50;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, totalHeight);
}

- (void)openApp:(UIButton *)sender {
    NSDictionary *app = self.allInstalledApps[sender.tag];
    NSString *bundleID = app[@"bundleID"];
    
    // Запускаем через приватный API
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:bundleID];
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
