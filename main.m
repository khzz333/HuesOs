
UIAlertController *renameAlert = [UIAlertController alertControllerWithTitle:@"Новое имя" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [renameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = app[@"name"];
        }];
        [renameAlert addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *newApp = [app mutableCopy];
            newApp[@"name"] = renameAlert.textFields.firstObject.text;
            [self.appsData replaceObjectAtIndex:index withObject:newApp];
            [self saveAndReload];
        }]];
        [renameAlert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:renameAlert animated:YES completion:nil];
    }]];

    // 2. Сменить действие (ссылку)
    [alert addAction:[UIAlertAction actionWithTitle:@"Сменить приложение (URL)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *urlAlert = [UIAlertController alertControllerWithTitle:@"Новая ссылка" message:@"Пример: youtube:// или cydia://" preferredStyle:UIAlertControllerStyleAlert];
        [urlAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = app[@"url"];
        }];
        [urlAlert addAction:[UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *newApp = [app mutableCopy];
            newApp[@"url"] = urlAlert.textFields.firstObject.text;
            [self.appsData replaceObjectAtIndex:index withObject:newApp];
            [self saveAndReload];
        }]];
        [urlAlert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:urlAlert animated:YES completion:nil];
    }]];

    // 3. Удалить
    [alert addAction:[UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.appsData removeObjectAtIndex:index];
        [self saveAndReload];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:nil]];
    
    // Для iPad (чтобы не крашилось)
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveAndReload {
    [[NSUserDefaults standardUserDefaults] setObject:self.appsData forKey:@"SavedApps"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupUI]; // Перерисовываем экран
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
16:55

