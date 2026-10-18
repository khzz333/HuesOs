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

// ВОЗВРАЩАЕМ СТАТУС-БАР
- (BOOL)prefersStatusBarHidden { return NO; }

- (void)setupUI {
    for (UIView *v in self.view.subviews) { [v removeFromSuperview]; }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 40)];
    title.text = @"Freedom OS"; 
    title.textColor = [UIColor whiteColor]; 
    title.font = [UIFont boldSystemFontOfSize:28];
    [self.view addSubview:title];

    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    editBtn.frame = CGRectMake(20, 90, 100, 30);
    [editBtn setTitle:@"+ Добавить" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [editBtn addTarget:self action:@selector(addNewListApp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];

    // ЛЕВАЯ КОЛОНКА
    for (int i = 0; i < self.listApps.count; i++) {
        NSDictionary *app = self.listApps[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 130 + (i * 50), self.view.bounds.size.width/2 - 30, 40);
        [btn setTitle:app[@"name"] forState:UIControlStateNormal]; 
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; 
        btn.titleLabel.font = [UIFont systemFontOfSize:18]; 
        btn.tag = i;
        
        [btn addTarget:self action:@selector(openListApp:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editListApp:)];
        [btn addGestureRecognizer:lp];
        
        [self.view addSubview:btn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, btn.frame.size.width, 1)]; 
        line.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0]; 
        [btn addSubview:line];
    }

    // ПРАВАЯ КОЛОНКА (ПЛИТКИ)
    CGFloat startY = 90;
    for (int i = 0; i < 6; i++) {
        id appData = self.gridApps[i];
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeSystem];
        int col = i % 2; int row = i / 2;
        tile.frame = CGRectMake(self.view.bounds.size.width/2 + 10 + (col * 75), startY + (row * 75), 65, 65);
        tile.layer.cornerRadius = 15; 
        tile.tag = i;
        
        if (appData == [NSNull null] || !appData) {
            tile.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0]; 
            [tile setTitle:@"+" forState:UIControlStateNormal]; 
            [tile setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; 
            tile.titleLabel.font = [UIFont systemFontOfSize:30];
            [tile addTarget:self action:@selector(addNewTile:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            tile.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0]; 
            [tile setTitle:appData[@"name"] forState:UIControlStateNormal]; 
            [tile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
            tile.titleLabel.font = [UIFont boldSystemFontOfSize:10]; 
            tile.titleLabel.numberOfLines = 2; 
            tile.titleLabel.textAlignment = NSTextAlignmentCenter;
            [tile addTarget:self action:@selector(openTile:) forControlEvents:UIControlEventTouchUpInside];
            
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editTile:)];
            [tile addGestureRecognizer:lp];
        }
        [self.view addSubview:tile];
    }

    // ПИТЕРЫ
    UIButton *peterLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    peterLeft.frame = CGRectMake(20, self.view.bounds.size.height - 160, 140, 140);
    NSData *dataLeft = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/en/c/c2/Peter_Griffin.png"]];
    if (dataLeft) { [peterLeft setImage:[UIImage imageWithData:dataLeft] forState:UIControlStateNormal]; peterLeft.imageView.contentMode = UIViewContentModeScaleAspectFit; }
    [peterLeft addTarget:self action:@selector(goToAllApps) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterLeft];

    UIButton *peterRight = [UIButton buttonWithType:UIButtonTypeCustom];
    peterRight.frame = CGRectMake(self.view.bounds.size.width - 160, self.view.bounds.size.height - 160, 140, 140);
    NSData *dataRight = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://i.pinimg.com/736x/8b/04/49/8b04494126e5e035f86bda7644c1c0cd.jpg"]];
    if (dataRight) { 
        [peterRight setImage:[UIImage imageWithData:dataRight] forState:UIControlStateNormal]; 
        peterRight.imageView.contentMode = UIViewContentModeScaleAspectFit; 
    } else {
        [peterRight setTitle:@"🚽" forState:UIControlStateNormal]; peterRight.titleLabel.font = [UIFont systemFontOfSize:80];
    }
    [peterRight addTarget:self action:@selector(openToilet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:peterRight];

    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToAllApps)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
}

- (void)openToilet { 
    NSURL *url = [NSURL URLWithString:@"firefox://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://google.com"] options:@{} completionHandler:nil];
    }
}

- (void)goToAllApps {
    AllAppsViewController *vc = [[AllAppsViewController alloc] init];
    NSMutableArray *all = [NSMutableArray arrayWithArray:self.listApps];
    for (id app in self.gridApps) { if (app != [NSNull null]) { [all addObject:app]; } }
    vc.myApps = all; 
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

// ЛЕВОЕ МЕНЮ
- (void)editListApp:(UILongPressGestureRecognizer *)g {
    if (g.state != UIGestureRecognizerStateBegan) return;
    UIButton *btn = (UIButton *)g.view; NSInteger tag = btn.tag;
    NSDictionary *app = self.listApps[tag];
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Настройка" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; tf.text = app[@"name"]; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; tf.text = app[@"url"]; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        if (a.textFields[0].text.length > 0) { self.listApps[tag] = @{@"name": a.textFields[0].text, @"url": a.textFields[1].text}; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *act) { [self.listApps removeObjectAtIndex:tag]; [self saveAll]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)addNewListApp {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Новое" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        if (a.textFields[0].text.length > 0) { [self.listApps addObject:@{@"name": a.textFields[0].text, @"url": a.textFields[1].text}]; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)openListApp:(UIButton *)sender { [self openURL:self.listApps[sender.tag][@"url"]]; }

// ПРАВЫЕ ПЛИТКИ
- (void)editTile:(UILongPressGestureRecognizer *)g {
    if (g.state != UIGestureRecognizerStateBegan) return;
    UIButton *btn = (UIButton *)g.view; NSInteger tag = btn.tag;
    NSDictionary *app = self.gridApps[tag];
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Настройка" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; tf.text = app[@"name"]; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; tf.text = app[@"url"]; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        if (a.textFields[0].text.length > 0) { self.gridApps[tag] = @{@"name": a.textFields[0].text, @"url": a.textFields[1].text}; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *act) { self.gridApps[tag] = [NSNull null]; [self saveAll]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)addNewTile:(UIButton *)sender {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Новое" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Название"; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Ссылка"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"ОК" style:UIAlertActionStyleDefault handler:^(UIAlertAction *act) {
        if (a.textFields[0].text.length > 0) { self.gridApps[sender.tag] = @{@"name": a.textFields[0].text, @"url": a.textFields[1].text}; [self saveAll]; }
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)openTile:(UIButton *)sender { [self openURL:self.gridApps[sender.tag][@"url"]]; }

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
    
    // ВОЗВРАЩАЕМ ВЕРХНЮЮ ПАНЕЛЬ НАВИГАЦИИ
    self.title = @"Все приложения";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; 
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO; 

    // ВОЗВРАЩАЕМ КНОПКУ "НАЗАД"
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];

    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds]; 
    [self.view addSubview:sv];

    int cols = 3; CGFloat sp = 20.0; CGFloat w = (self.view.bounds.size.width - (sp * (cols + 1))) / cols; CGFloat h = w + 30;
    
    for (int i = 0; i < self.myApps.count; i++) {
        int c = i % cols; int r = i / cols;
        // Сдвинули вниз, чтобы не перекрывать верхнюю панель
        UIView *cont = [[UIView alloc] initWithFrame:CGRectMake(sp + (c * (w + sp)), 80 + (r * (h + sp)), w, h)];
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom]; 
        b.frame = CGRectMake(0, 0, w, w); 
        b.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0]; 
        b.layer.cornerRadius = 20;
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
    sv.contentSize = CGSizeMake(self.view.bounds.size.width, (self.myApps.count / cols + 1) * (h + sp) + 100);
}

- (void)goBack { [self dismissViewControllerAnimated:YES completion:nil]; }

- (void)openApp:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:self.myApps[sender.tag][@"url"]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) { [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil]; }
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

int main(int argc, char * argv[]) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class])); } }
