#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

// 充值选项数据模型
@interface WZRechargeOption : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *priceDisplay;
@property (nonatomic, assign) float price;
@end

@implementation WZRechargeOption
@end

// 充值面板控制器
@interface WZRechargeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<WZRechargeOption *> *rechargeOptions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, SKProduct *> *products;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation WZRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    self.products = [NSMutableDictionary dictionary];
    
    // 初始化充值选项
    [self setupRechargeOptions];
    
    // 创建容器视图
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(30, 80, self.view.bounds.size.width - 60, self.view.bounds.size.height - 160)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 15;
    containerView.clipsToBounds = YES;
    [self.view addSubview:containerView];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, containerView.bounds.size.width, 60)];
    titleLabel.text = @"快速充值";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    titleLabel.textColor = [UIColor whiteColor];
    [containerView addSubview:titleLabel];
    
    // 充值选项列表
    CGRect tableFrame = CGRectMake(0, 60, containerView.bounds.size.width, containerView.bounds.size.height - 120);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 70;
    [containerView addSubview:self.tableView];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, containerView.bounds.size.height - 60, containerView.bounds.size.width, 30)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.text = @"正在加载商品信息...";
    [containerView addSubview:self.statusLabel];
    
    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = CGPointMake(containerView.bounds.size.width / 2, containerView.bounds.size.height - 45);
    [self.loadingIndicator startAnimating];
    [containerView addSubview:self.loadingIndicator];
    
    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(self.view.bounds.size.width - 60, 30, 50, 50);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightLight];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // 添加手势识别，点击背景关闭
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    // 注册为支付观察者
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // 加载产品信息
    [self loadProducts];
}

- (void)setupRechargeOptions {
    NSMutableArray *options = [NSMutableArray array];
    
    // 根据抓包数据，添加不同的充值选项
    NSArray *products = @[
        @{@"title": @"60点券", @"productId": @"com.tencent.smoba60_60", @"price": @6.0},
        @{@"title": @"450点券", @"productId": @"com.tencent.smoba450_450", @"price": @45.0},
        @{@"title": @"900点券", @"productId": @"com.tencent.smoba900_900", @"price": @90.0},
        @{@"title": @"1800点券", @"productId": @"com.tencent.smoba1800_1800", @"price": @180.0},
        @{@"title": @"3000点券", @"productId": @"com.tencent.smoba3000_3000", @"price": @300.0},
        @{@"title": @"6000点券", @"productId": @"com.tencent.smoba6000_6000", @"price": @600.0}
    ];
    
    for (NSDictionary *product in products) {
        WZRechargeOption *option = [[WZRechargeOption alloc] init];
        option.title = product[@"title"];
        option.productId = product[@"productId"];
        option.price = [product[@"price"] floatValue];
        option.priceDisplay = [NSString stringWithFormat:@"¥%.0f", option.price];
        [options addObject:option];
    }
    
    self.rechargeOptions = options;
}

- (void)loadProducts {
    // 获取所有产品 ID
    NSMutableSet *productIds = [NSMutableSet set];
    for (WZRechargeOption *option in self.rechargeOptions) {
        [productIds addObject:option.productId];
    }
    
    // 请求产品信息
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        
        if (response.products.count > 0) {
            for (SKProduct *product in response.products) {
                self.products[product.productIdentifier] = product;
            }
            
            [self.tableView reloadData];
            self.statusLabel.text = [NSString stringWithFormat:@"已加载 %lu 个商品", (unsigned long)response.products.count];
        } else {
            self.statusLabel.text = @"暂无可用商品";
        }
        
        if (response.invalidProductIdentifiers.count > 0) {
            NSLog(@"[WZHelper] 无效的产品ID: %@", response.invalidProductIdentifiers);
        }
    });
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        self.statusLabel.text = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" 
                                                                       message:[NSString stringWithFormat:@"无法加载商品信息：%@", error.localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rechargeOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"RechargeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    WZRechargeOption *option = self.rechargeOptions[indexPath.row];
    SKProduct *product = self.products[option.productId];
    
    cell.textLabel.text = option.title;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    
    if (product) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = product.priceLocale;
        NSString *priceString = [formatter stringFromNumber:product.price];
        cell.detailTextLabel.text = priceString;
    } else {
        cell.detailTextLabel.text = option.priceDisplay;
    }
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WZRechargeOption *option = self.rechargeOptions[indexPath.row];
    [self purchaseProduct:option];
}

#pragma mark - 购买逻辑

- (void)purchaseProduct:(WZRechargeOption *)option {
    // 检查是否可以进行支付
    if (![SKPaymentQueue canMakePayments]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法购买" 
                                                                       message:@"当前设备不支持应用内购买"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    SKProduct *product = self.products[option.productId];
    
    if (!product) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"商品未加载" 
                                                                       message:@"请稍后再试"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 确认购买
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = product.priceLocale;
    NSString *priceString = [formatter stringFromNumber:product.price];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认购买" 
                                                                   message:[NSString stringWithFormat:@"确定要购买 %@ (%@) 吗？", option.title, priceString]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self executePurchase:product];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)executePurchase:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    self.statusLabel.text = @"正在处理购买...";
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"[WZHelper] 购买中: %@", transaction.payment.productIdentifier);
                break;
                
            case SKPaymentTransactionStatePurchased:
                NSLog(@"[WZHelper] 购买成功: %@", transaction.payment.productIdentifier);
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"[WZHelper] 购买失败: %@", transaction.error.localizedDescription);
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"[WZHelper] 恢复购买: %@", transaction.payment.productIdentifier);
                [self restoreTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateDeferred:
                NSLog(@"[WZHelper] 购买延迟: %@", transaction.payment.productIdentifier);
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = @"购买成功！";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"购买成功" 
                                                                       message:@"点券将很快到账，请稍候查看"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self closePanel];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (transaction.error.code != SKErrorPaymentCancelled) {
            self.statusLabel.text = @"购买失败";
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"购买失败" 
                                                                           message:transaction.error.localizedDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            self.statusLabel.text = @"已取消购买";
        }
    });
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - 界面交互

- (void)closePanel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    
    // 只有点击在容器视图外部时才关闭
    UIView *containerView = self.view.subviews[0];
    if (!CGRectContainsPoint(containerView.frame, location)) {
        [self closePanel];
    }
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end

#pragma mark - Hook 王者荣耀

// Hook 主窗口，添加悬浮按钮
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 检查是否是王者荣耀的主窗口
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.tencent.smoba"]) {
            UIWindow *window = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [window performSelector:@selector(addFloatingButton)];
            });
        }
    });
}

%new
- (void)addFloatingButton {
    // 检查是否已经添加过按钮
    UIButton *existingButton = (UIButton *)[self viewWithTag:9999];
    if (existingButton) {
        [self bringSubviewToFront:existingButton];
        return;
    }
    
    // 创建悬浮按钮
    UIButton *floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, 200, 60, 60);
    floatingButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.9];
    floatingButton.layer.cornerRadius = 30;
    floatingButton.layer.shadowColor = [UIColor blackColor].CGColor;
    floatingButton.layer.shadowOffset = CGSizeMake(0, 2);
    floatingButton.layer.shadowOpacity = 0.3;
    floatingButton.layer.shadowRadius = 4;
    floatingButton.layer.zPosition = 999;
    
    // 设置按钮图标
    [floatingButton setTitle:@"💎" forState:UIControlStateNormal];
    floatingButton.titleLabel.font = [UIFont systemFontOfSize:30];
    
    [floatingButton addTarget:self action:NSSelectorFromString(@"showRechargePanel") forControlEvents:UIControlEventTouchUpInside];
    
    // 添加拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(@"handlePan:")];
    [floatingButton addGestureRecognizer:panGesture];
    
    floatingButton.tag = 9999; // 标记这个按钮
    [self addSubview:floatingButton];
    [self bringSubviewToFront:floatingButton];
}

// Hook layoutSubviews 确保按钮始终在最上层
- (void)layoutSubviews {
    %orig;
    
    UIButton *floatingButton = (UIButton *)[self viewWithTag:9999];
    if (floatingButton) {
        [self bringSubviewToFront:floatingButton];
    }
}

%new
- (void)showRechargePanel {
    UIViewController *rootVC = self.rootViewController;
    
    // 找到最顶层的视图控制器
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    
    WZRechargeViewController *rechargeVC = [[WZRechargeViewController alloc] init];
    rechargeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    rechargeVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [rootVC presentViewController:rechargeVC animated:YES completion:nil];
}

%new
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIButton *button = (UIButton *)gesture.view;
    CGPoint translation = [gesture translationInView:self];
    
    button.center = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
    
    [gesture setTranslation:CGPointZero inView:self];
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // 自动贴边
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat newX = button.center.x < screenWidth / 2 ? 30 : screenWidth - 30;
        
        [UIView animateWithDuration:0.3 animations:^{
            button.center = CGPointMake(newX, button.center.y);
        }];
    }
}

%end

// 可选：Hook 广告弹窗，自动关闭
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // 检测是否是广告弹窗（根据类名或视图特征判断）
    NSString *className = NSStringFromClass([self class]);
    
    // 这里需要根据实际抓包或调试找到广告弹窗的类名
    // 例如：if ([className containsString:@"Ad"] || [className containsString:@"Promotion"])
    // 可以通过 Reveal 或 Flex 等工具分析王者荣耀的视图结构
    
    if ([className containsString:@"Ad"] || 
        [className containsString:@"Promotion"] ||
        [className containsString:@"Banner"]) {
        
        NSLog(@"[WZHelper] 检测到广告弹窗: %@", className);
        
        // 自动关闭（可在设置中配置是否启用）
        NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourname.wangzhehelper.plist"];
        
        if ([preferences[@"autoCloseAds"] boolValue]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
}

%end

%ctor {
    NSLog(@"[WZHelper] 王者荣耀快速充值插件已加载");
}

