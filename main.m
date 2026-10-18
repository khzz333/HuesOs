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
    // Левый Питер (Открывает меню всех приложений)
    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    // Ссылка на картинку Питера (прозрачный фон)
    NSURL *urlLeft = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"];
    NSData *dataLeft = [NSData dataWithContentsOfURL:urlLeft];
    [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal];
    peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    // Правый Ретип (Открывает Safari)
    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    // Ссылка на картинку Ретипа (в зеленой рубашке)
    NSURL *urlRight = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/5/5b/Retep_Griffin.png"];
    NSData *dataRight = [NSData dataWithContentsOfURL:urlRight];
    [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal];
    peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [peterRight addTarget:self action:@selector(openSafari) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];
}

// ================= ДЕЙСТВИЯ =================
- (void)goToAllApps {
    // Создаем простой экран со всеми приложениями (заглушка)
    UIViewController *allAppsVC = [[UIViewController alloc] init];
    allAppsVC.view.backgroundColor = [UIColor darkGrayColor];
    allAppsVC.title = @"Все приложения";
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    lbl.center = allAppsVC.view.center;
    lbl.text = @"Тут будет сетка всех приложений";
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [allAppsVC.view addSubview:lbl];

    // Показываем его модально (снизу вверх)
    [self presentViewController:allAppsVC animated:YES completion:nil];
}

- (void)openSafari {
    // Открываем Safari по ссылке
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
    // Тут код редактирования левой колонки (как был раньше)
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
