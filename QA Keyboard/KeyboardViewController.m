//
//  KeyboardViewController.m
//  QA Keyboard
//
//  Created by Eugene on 8/21/15.
//  Copyright (c) 2015 Techery. All rights reserved.
//

#import "KeyboardViewController.h"
#import "QABoardConstants.h"
#import "Masonry.h"

@interface KeyboardViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *nextKeyboardButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *literalButton;
@property (nonatomic, strong) UIButton *testerButton;

@property (nonatomic, assign) BOOL isWordsSelected;
@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) NSDictionary *testerDictionary;

@property (nonatomic, strong) NSUserDefaults *sharedSettings;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadButtons];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.contentView addSubview:self.tableView];
    
    [self setupConstraints];
    [self loadWords];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

#pragma mark - UI Helpers

- (void)loadButtons {
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next Keyboard", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextKeyboardButton];
    
    self.literalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.literalButton setTitle:@"Phrases" forState:UIControlStateNormal];
    self.literalButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.literalButton];
    [self.literalButton addTarget:self action:@selector(loadWords) forControlEvents:UIControlEventTouchUpInside];
    
    self.testerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.testerButton setTitle:@"Testers" forState:UIControlStateNormal];
    self.testerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.testerButton];
    [self.testerButton addTarget:self action:@selector(loadTestersData) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupConstraints {
    
    [self.nextKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(@(0));
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.literalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextKeyboardButton.mas_right);
        make.top.equalTo(@(0));
        make.height.equalTo(self.nextKeyboardButton);
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.testerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.literalButton.mas_right);
        make.top.equalTo(@(0));
        make.height.equalTo(self.nextKeyboardButton);
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nextKeyboardButton.mas_bottom);
        make.left.equalTo(@(0));
        make.width.equalTo(self.view);
        make.bottom.equalTo(@(0));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark - Logic Helpers

- (void)loadWords {
    if (self.isWordsSelected) {
        return;
    }
    self.isWordsSelected = YES;
    
    NSURL *url = [NSURL URLWithString:[self.sharedSettings objectForKey:kWordsKey]];
    if (url.absoluteString.length < 1) {
        NSData *jsonData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"default_words" ofType:@"json"]];
        [self reloadWordsTableViewWithJSONData:jsonData];
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak KeyboardViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSData *jsonData = data;
        if (!jsonData || connectionError) {
            jsonData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"default_words" ofType:@"json"]];
            if (!jsonData) {
                return;
            }
        }
        [weakSelf reloadWordsTableViewWithJSONData:jsonData];
    }];
}

- (void)loadTestersData {
    if (!self.isWordsSelected) {
        return;
    }
    self.isWordsSelected = NO;
    
    NSURL *url = [NSURL URLWithString:[self.sharedSettings objectForKey:kTestersKey]];
    if (url.absoluteString.length < 1) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak KeyboardViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!data || connectionError) {
            return;
        }
        NSError *error = nil;
        NSDictionary *jsonDicitonary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonDicitonary.count > 0 && !error) {
            weakSelf.testerDictionary = [NSDictionary dictionaryWithDictionary:jsonDicitonary];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)reloadWordsTableViewWithJSONData:(NSData *)jsonData {
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (jsonArray.count > 0 && !error) {
        self.words = [NSArray arrayWithArray:jsonArray];
        [self.tableView reloadData];
    }
}

- (NSUserDefaults *)sharedSettings {
    if (!_sharedSettings) {
        _sharedSettings = [[NSUserDefaults alloc] initWithSuiteName:kQABoardDefaults];
    }
    return _sharedSettings;
}

#pragma mark - Input View Controller

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isWordsSelected) {
        return self.words.count;
    }
    else {
        return [[self.testerDictionary allKeys] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                                            forIndexPath:indexPath];
    
    if (self.isWordsSelected) {
        cell.textLabel.text = [self.words objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [[self.testerDictionary allKeys] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text =nil;
    
    if (self.isWordsSelected) {
        text = [self.words objectAtIndex:indexPath.row];
    }
    else {
        NSString *key = [[self.testerDictionary allKeys] objectAtIndex:indexPath.row];
        text = [self.testerDictionary objectForKey:key];
    }
    [self.textDocumentProxy insertText:text];
}

@end




