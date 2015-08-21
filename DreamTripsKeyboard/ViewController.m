//
//  ViewController.m
//  DreamTripsKeyboard
//
//  Created by Vladimir Bondarev on 8/18/15.
//  Copyright (c) 2015 Vladimir Bondarev. All rights reserved.
//

#import "ViewController.h"
#import "DreamTripsKeyboardConstants.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField *wordsTextField;
@property (nonatomic, weak) IBOutlet UITextField *testersTextField;
@property (nonatomic, strong) NSUserDefaults *sharedSettings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wordsTextField.text = [self.sharedSettings objectForKey:kWordsKey];
    self.testersTextField.text = [self.sharedSettings objectForKey:kTestersKey];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];

}

- (void)handleEnteredBackground {
    [self.sharedSettings setObject:self.wordsTextField.text forKey:kWordsKey];
    [self.sharedSettings setObject:self.testersTextField.text forKey:kTestersKey];
    [self.sharedSettings synchronize];
}

- (NSUserDefaults *)sharedSettings {
    if (!_sharedSettings) {
        _sharedSettings = [[NSUserDefaults alloc] initWithSuiteName:KDreamTripsDefaults];
    }
    return _sharedSettings;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
