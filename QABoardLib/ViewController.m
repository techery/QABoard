
#import "ViewController.h"
#import "QABoardConstants.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField *wordsTextField;
@property (nonatomic, weak) IBOutlet UITextField *testersTextField;
@property (nonatomic, strong) NSUserDefaults *sharedSettings;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredBackground)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wordsTextField.text = [self.sharedSettings objectForKey:kWordsKey];
    self.testersTextField.text = [self.sharedSettings objectForKey:kTestersKey];
}

- (void)handleEnteredBackground {
    [self.sharedSettings setObject:self.wordsTextField.text forKey:kWordsKey];
    [self.sharedSettings setObject:self.testersTextField.text forKey:kTestersKey];
    [self.sharedSettings synchronize];
}

- (NSUserDefaults *)sharedSettings {
    if (!_sharedSettings) {
        _sharedSettings = [[NSUserDefaults alloc] initWithSuiteName:kQABoardDefaults];
    }
    return _sharedSettings;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
