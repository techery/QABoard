//
//  KeyboardViewController.m
//  QA Keyboard
//
//  Created by Eugene on 8/21/15.
//  Copyright (c) 2015 Techery. All rights reserved.
//

#import "KeyboardViewController.h"
#import "QABoardConstants.h"

@interface KeyboardViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *nextKeyboardButton;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *literalButton;
@property (nonatomic, weak) IBOutlet UIButton *testerButton;

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
    
    UINib *nib = [UINib nibWithNibName:@"QAKeyboardView" bundle:nil];
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    self.view = views.firstObject;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [self loadWords:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

#pragma mark - Logic Helpers

- (IBAction)nextKeyboardPressed:(id)sender {
    [self advanceToNextInputMode];
}

- (IBAction)loadWords:(id)sender {
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

- (IBAction)loadTestersData:(id)sender {
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




