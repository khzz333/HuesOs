#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface AllAppsViewController : UIViewController
@property (nonatomic, strong) NSArray *myApps;
@end

@interface MainMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *listApps;
@property (nonatomic, strong) NSMutableArray *gridApps;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *sl = [defs objectForKey:@"SL"]; 
    NSArray *sg = [defs objectForKey:@"SG"];
    
    self.listApps = sl ? [sl mutableCopy] : [@[@{@"name": @"Sileo", @"url": @"sileo://"}, @{@"name": @"Filza", @"url": @"filza://"}, @{@"name": @"Настройки", @"url": @"App-Prefs://"}, @{@"name": @"Файлы", @"url": @"shareddocuments://"}] mutableCopy];
    self.gridApps = sg ? [sg mutableCopy] : [@[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]] mutableCopy];
    
    [self setupUI];
}

- (void)setupUI {
    for (UIView *v in self.view.subviews) { [v removeFromSuperview]; }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 200, 40)];
    title.text = @"Freedom OS"; 
    title.textColor = [UIColor whiteColor]; 
    title.font = [UIFont boldSystemFontOfSize:28];
    [self.view addSubview:title];

    // Кнопка редактирования
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    editBtn.frame = CGRectMake(20, 100, 100, 30);
    [editBtn setTitle:@"Изменить" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [editBtn addTarget:self action:@selector(addListApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];

    // ЛЕВАЯ КОЛОНКА
    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 140 + (i * 50), self.view.bounds.size.width/2 - 30, 40);
        [btn setTitle:app[@"name"] forState:UIControlStateNormal]; 
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; 
        btn.titleLabel.font = [UIFont systemFontOfSize:18]; 
        btn.tag = i;
        [btn addTarget:self action:@selector(openListApp:) forControlEvents:UIControlEventTouchUpInside];
        
        // Долгое нажатие для редактирования
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editItem:)];
        [btn addGestureRecognizer:lp];
        
        [self.view addSubview:btn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, btn.frame.size.width, 1)]; 
        line.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0]; 
        [btn addSubview:line];
    }

    // ПРАВАЯ КОЛОНКА (ПЛИТКИ) - ВЫРАВНИВАЕМ ПО ВЕРХУ
    CGFloat startY = 95; // Уровень с кнопкой "Изменить"
    for (int i = 0; i < 6; i++) {
        id appData = self.gridApps[i];
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        int col = i % 2; int row = i / 2;
        // Размер 70х70, отступ 75, чтобы влезло в высоту
        tile.frame = CGRectMake(self.view.bounds.size.width/2 + 10 + (col * 75), startY + (row * 75), 65, 65);
        tile.layer.cornerRadius = 15; 
        tile.tag = i;
        
        if (appData == [NSNull null] || !appData) {
            tile.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0]; 
            [tile setTitle:@"+" forState:UIControlStateNormal]; 
            [tile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; 
            tile.titleLabel.font = [UIFont systemFontOfSize:30];
            [tile addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            tile.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0]; 
            [tile setTitle:appData[@"name"] forState:UIControlStateNormal]; 
            [tile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
            tile.titleLabel.font = [UIFont boldSystemFontOfSize:10]; 
            tile.titleLabel.numberOfLines = 2; 
            tile.titleLabel.textAlignment = NSTextAlignmentCenter;
            [tile addTarget:self action:@selector(openTile:) forControlEvents:UIControlEventTouchUpInside];
            
            // Долгое нажатие для редактирования плитки
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editItem:)];
            [tile addGestureRecognizer:lp];
        }
        [self.view addSubview:tile];
    }

    // ПИТЕРЫ ВНИЗУ
    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    NSData *dataLeft = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"]];
    if (dataLeft) { [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal]; peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit; }
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    // Новая ссылка на Питера с унитазом
    NSData *dataRight = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://i.pinimg.com/736x/8b/04/49/8b04494126e5e035f86bda7644c1c0cd.jpg"]];
    if (dataRight) { 
        [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal]; 
        peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit; 
    } else {
        // Если интернета нет - пишем текст
        [peterRight setTitle:@"🚽" forState:UIControlStateNormal];
        peterRight.titleLabel.font = [UIFont systemFontOfSize:80];
    }
    [peterRight addTarget:self action:@selector(openFirefox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];
}

- (void)openFirefox { [self openURL:@"firefox://"]; }

- (void)goToAllApps {
    AllAppsViewController *vc = [[AllAppsViewController alloc] init];
    vc.myApps = self.listApps; // Передаем туда наш список
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

// УНИВЕРСАЛЬНОЕ РЕДАКТИРОВАНИЕ (и для левого списка, и для плиток)
- (void)editItem:(id)sender {
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *g = (UILongPressGestureRecognizer *)sender;
        if (g.state != UIGestureRecognizerStateBegan) return;
    }
    
    UIButton *btn = (UIButton *)([sender isKindOfClass:[UIGestureRecognizer class]] ? ((UIGestureRecognizer *)sender).view : sender);
    NSInteger tag = btn.tag;
    BOOL isLeftList = (btn.frame.origin.x < self.view.bounds.size.width / 2);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Настройка" message:@"Введите название и ссылку" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { 
        tf.placeholder = @"Название"; 
        if (isLeftList) { tf.text = self.listApps[tag][@"name"]; } 
        else if (self.gridApps[tag] != [NSNull null]) { tf.text = self.gridApps[tag][@"name"]; }
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { 
        tf.placeholder = @"Ссылка (tg://, sileo://)"; 
        if (isLeftList) { tf.text = self.listApps[tag][@"url"]; } 
        else if (self.gridApps[tag] != [NSNull null]) { tf.text = self.gridApps[tag][@"url"]; }
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        NSString *n = alert.textFields[0].text; NSString *u = alert.textFields[1].text;
        if (n.length > 0 && u.length > 0) {
            NSDictionary *newApp = @{@"name": n, @"url": u};
            if (isLeftList) {
                if (tag < self.listApps.count) { self.listApps[tag] = newApp; }
                else { [self.listApps addObject:newApp]; }
            } else {
                self.gridApps[tag] = newApp;
            }
            [self saveAll];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *act) {
        if (isLeftList) {
            if (tag < self.listApps.count) { [self.listApps removeObjectAtIndex:tag]; }
        } else {
            self.gridApps[tag] = [NSNull null];
        }
        [self saveAll];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// Старая кнопка "Изменить" просто вызывает редактор для добавления нового элемента
- (void)addListApp {
    NSInteger newIndex = self.listApps.count;
    [self.listApps addObject:@{@"name": @"Новое", @"url": @"https://"}];
    [self saveAll];
}

- (void)openTile:(UIButton *)sender { [self openURL:self.gridApps[sender.tag][@"url"]]; }
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

// ================= ЭКРАН СЕТКИ =================
@implementation AllAppsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor]; 
    self.title = @"Мои приложения";
    
    // Кнопка Назад
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // Свайп вправо для выхода
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];

    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds]; 
    [self.view addSubview:sv];

    int cols = 3; 
    CGFloat sp = 20.0; 
    CGFloat w = (self.view.bounds.size.width - (sp * (cols + 1))) / cols; 
    CGFloat h = w + 30;
    
    for (int i = 0; i < self.myApps.count; i++) {
        int c = i % cols; int r = i / cols;
        UIView *cont = [[UIView alloc] initWithFrame:CGRectMake(sp + (c * (w + sp)), 20 + (r * (h + sp)), w, h)];
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom]; 
        b.frame = CGRectMake(0, 0, w, w); 
        b.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0]; 
        b.layer.cornerRadius = 20;
        
        // Если знаешь, как вытащить иконку, вставь сюда. Пока просто название.
        [b setTitle:self.myApps[i][@"name"] forState:UIControlStateNormal];
        [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        b.titleLabel.numberOfLines = 2;
        b.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [b addTarget:self action:@selector(openApp:) forControlEvents:UIControlEventTouchUpInside]; 
        b.tag = i; 
        [cont addSubview:b];
        
        [sv addSubview:cont];
    }
    sv.contentSize = CGSizeMake(self.view.bounds.size.width, (self.myApps.count / cols + 1) * (h + sp) + 50);
}

- (void)goBack { [self dismissViewControllerAnimated:YES completion:nil]; }

- (void)openApp:(UIButton *)sender {
    NSDictionary *app = self.myApps[sender.tag];
    NSURL *url = [NSURL URLWithString:app[@"url"]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
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
