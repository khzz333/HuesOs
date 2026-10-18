#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *listApps; // Левая колонка
@property (nonatomic, strong) NSMutableArray *gridApps; // Правая колонка (плитки)
@property (nonatomic, strong) UIView *gridContainer;    // Контейнер для плиток
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // Загрузка данных
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedList = [defaults objectForKey:@"SavedList"];
    NSArray *savedGrid = [defaults objectForKey:@"SavedGrid"];
    
    self.listApps = savedList ? [savedList mutableCopy] : [@[
        @{@"name": @"Sileo", @"url": @"sileo://"},
        @{@"name": @"Filza", @"url": @"filza://"},
        @{@"name": @"Настройки", @"url": @"App-Prefs://"},
        @{@"name": @"Файлы", @"url": @"shareddocuments://"}
    ] mutableCopy];
    
    // Правая колонка (5 слотов, изначально пустые)
    self.gridApps = savedGrid ? [savedGrid mutableCopy] : [@[
        [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]
    ] mutableCopy];

    [self setupUI];
}

- (void)setupUI {
    for (UIView *view in self.view.subviews) { [view removeFromSuperview]; }

    // ЗАГОЛОВОК
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 300, 40)];
    titleLabel.text = @"Freedom OS";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:titleLabel];

    // ЛЕВАЯ КОЛОНКА (СПИСОК)
    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        // Ширина списка — половина экрана
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

    // ПРАВАЯ КОЛОНКА (ПЛИТКИ)
    self.gridContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 + 10, 120, self.view.bounds.size.width / 2 - 20, 300)];
    [self.view addSubview:self.gridContainer];

    for (int i = 0; i < 5; i++) {
        id appData = self.gridApps[i];
        
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        int col = i % 2;
        int row = i / 2;
        tile.frame = CGRectMake(col * 85, row * 85, 75, 75);
        
        tile.layer.cornerRadius = 15;
        tile.tag = i;
        
        if (appData == [NSNull null] || !appData) {
            // ПУСТАЯ ПЛИТКА
            tile.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
            [tile setTitle:@"+" forState:UIControlStateNormal];
            [tile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            tile.titleLabel.font = [UIFont systemFontOfSize:30];
            [tile addTarget:self action:@selector(addTile:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            // ЗАНЯТАЯ ПЛИТКА
            tile.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
            [tile setTitle:appData[@"name"] forState:UIControlStateNormal];
            [tile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            tile.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            tile.titleLabel.numberOfLines = 2;
            tile.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [tile addTarget:self action:@selector(openTile:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTile:)];
            [tile addGestureRecognizer:lp];
        }
        
        [self.gridContainer addSubview:tile];
    }
}

// ================= ДЕЙСТВИЯ ДЛЯ СПИСКА (СЛЕВА) =================
- (void)openListApp:(UIButton *)sender {
    NSDictionary *app = self.listApps[sender.tag];
    [self openURL:app[@"url"]];
}

- (void)editListApp:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    UIButton *btn = (UIButton *)gesture.view;
    NSDictionary *app = self.listApps[btn.tag];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Настройки" message:app[@"name"] preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Сменить ссылку" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Новая ссылка" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [a addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull tf) { tf.text = app[@"url"]; }];
        [a addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *newApp = [app mutableCopy];
            newApp[@"url"] = a.textFields.firstObject.text;
            self.listApps[btn.tag] = newApp;
            [self saveAll];
        }]];
        [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:a animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// ================= ДЕЙСТВИЯ ДЛЯ ПЛИТОК (СПРАВА) =================
- (void)addTile:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Новая плитка" message:@"Введи название и ссылку" preferredStyle:UIAlertControllerStyleAlert];
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

// ================= ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =================
- (void)openURL:(NSString *)urlStr {NSURL *url = [NSURL URLWithString:urlStr];
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

