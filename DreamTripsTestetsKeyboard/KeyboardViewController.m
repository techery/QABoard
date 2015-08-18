//
//  KeyboardViewController.m
//  DreamTripsKeyboard
//
//  Created by Vladimir Bondarev on 8/17/15.
//  Copyright (c) 2015 Vladimir Bondarev. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Masonry.h"

static NSString * const CellReuseID = @"CellReuseID";

@interface KeyboardViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *literalButton;
@property (nonatomic, strong) UIButton *testerButton;

@property (nonatomic, assign) BOOL isWords;
@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) NSDictionary *testerDictionary;

@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    self.isWords = NO;
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellReuseID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.contentView addSubview:self.tableView];
    
    [self updateViewConstraints];
    [self loadWords];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self.nextKeyboardButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(@(0));
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.literalButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextKeyboardButton.mas_right);
        make.top.equalTo(@(0));
        make.height.equalTo(self.nextKeyboardButton);
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.testerButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.literalButton.mas_right);
        make.top.equalTo(@(0));
        make.height.equalTo(self.nextKeyboardButton);
        make.width.equalTo(self.view).multipliedBy(0.33);
    }];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nextKeyboardButton.mas_bottom);
        make.left.equalTo(@(0));
        make.width.equalTo(self.view);
        make.bottom.equalTo(@(0));
    }];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setupButtons {
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

- (void)textWillChange:(id<UITextInput>)textInput {
}

- (void)textDidChange:(id<UITextInput>)textInput {
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)loadWords {
    if (self.isWords) {
        return;
    }
    self.isWords = !self.isWords;
    
    NSURL *url = [NSURL URLWithString:@"https://www.dropbox.com/s/ftb88f48d3e38k6/blns.json?dl=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak KeyboardViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!data || connectionError) {
            return;
        }
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonArray.count > 0 && !error) {
            weakSelf.words = [NSArray arrayWithArray:jsonArray];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)loadTestersData {
    if (!self.isWords) {
        return;
    }
    self.isWords = !self.isWords;
    
    NSURL *url = [NSURL URLWithString:@"https://www.dropbox.com/s/hqvyukgao8deglt/testers.json?dl=1"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isWords) {
        return self.words.count;
    }
    else {
        return [[self.testerDictionary allKeys] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseID forIndexPath:indexPath];
    
    if (self.isWords) {
        cell.textLabel.text = [self.words objectAtIndex:indexPath.row];
    }
    else {
        cell.textLabel.text = [[self.testerDictionary allKeys] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text =nil;
    
    if (self.isWords) {
        text = [self.words objectAtIndex:indexPath.row];
    }
    else {
        NSString *key = [[self.testerDictionary allKeys] objectAtIndex:indexPath.row];
        text = [self.testerDictionary objectForKey:key];
    }
    [self.textDocumentProxy insertText:text];
    [self.textDocumentProxy insertText:@"\n"];
}

@end
