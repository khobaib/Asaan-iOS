//
//  DropdownView.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "DropdownView.h"

@interface DropdownView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    int _currentSelction;
    bool _listShowed;
}

- (void)setup;
- (void)setupDropdownButton;
- (void)setupDropdownTableView;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *dropdownImageView;
@property (nonatomic, strong) UITableView* listTableView;

@end

@implementation DropdownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect frame1 = {.origin = {0, 0}, .size = {self.frame.size.width - 25, self.frame.size.height}};
    self.titleLabel.frame = frame1;
    
    CGRect frame2 = {.origin = {self.frame.size.width - 20, 5}, .size = {20, self.frame.size.height - 10}};
    self.dropdownImageView.frame = frame2;
    
    CGRect frame3 = {.origin = {self.frame.origin.x - 10, self.frame.origin.y + self.frame.size.height}, .size = {self.frame.size.width + 20, 100}};
    self.listTableView.frame = frame3;
}

#pragma mark - Private Methods
- (void)setup
{
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _data = @[@"No Item"];
    _currentSelction = 0;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    self.tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.tapGestureRecognizer];

    
    [self setupDropdownButton];
    [self setupDropdownTableView];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.dropdownImageView];
    
    [self hideList];
}

- (void)setupDropdownButton
{
    CGRect frame = {.origin = {0, 0}, .size = {self.frame.size.width - 25, self.frame.size.height}};
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = _data[_currentSelction];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    CGRect frame1 = {.origin = {self.frame.size.width - 20, 5}, .size = {20, self.frame.size.height - 10}};
    self.dropdownImageView = [[UIImageView alloc] initWithFrame:frame1];
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_down"];
    self.dropdownImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupDropdownTableView
{
    CGRect frame = {.origin = {self.frame.origin.x - 10, self.frame.origin.y + self.frame.size.height}, .size = {self.frame.size.width + 20, 100}};
    self.listTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    CALayer *layer = self.listTableView.layer;
    layer.cornerRadius = 3.0;
    layer.borderWidth = 1.0;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.listTableView.backgroundColor = [UIColor whiteColor];
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
}

#pragma mark - Public Methods
- (void)setData:(NSArray *)data {

    @synchronized(self) {
        
        if (data) {
            NSMutableArray* temp = [NSMutableArray arrayWithArray:data];
            [temp addObject:@""];
            _data = temp;
        }
    }
    
    self.titleLabel.text = _data[_currentSelction];
}

- (void)setDefaultSelection:(int)defaultSelection {
    
    @synchronized(self) {
    
        if (defaultSelection >=0 && defaultSelection < _data.count) {
            _currentSelction = defaultSelection;
        }
    }

    self.titleLabel.text = _data[_currentSelction];
}

- (void)showList
{
    _listShowed = true;
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_up"];
    [self.superview addSubview:self.listTableView];
}

- (void)hideList
{
    
    _listShowed = false;
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_down"];
    [self.listTableView removeFromSuperview];
}

#pragma mark - Actions
- (IBAction)respondToTapGesture:(id)sender
{
    [self.superview endEditing:YES];
    
    NSLog(@"Jello");
    if (_listShowed) {
        [self hideList];
    }
    else {
        [self showList];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)l_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"DropdownCellList";
    UITableViewCell *cell = [l_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        //If not possible create a new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    
    if (indexPath.row == _currentSelction) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)l_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"hello");
    _currentSelction = (int)indexPath.row;
    self.titleLabel.text = self.data[_currentSelction];
    
    [self.delegate dropdownViewActionForSelectedRow:(int)indexPath.row sender:self];
    [l_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self hideList];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
