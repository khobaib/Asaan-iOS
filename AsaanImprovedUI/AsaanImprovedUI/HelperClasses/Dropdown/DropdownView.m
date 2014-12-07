//
//  DropdownView.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "DropdownView.h"

#define DEBUG_DropdownView_HASAN false

#define DDImageViewFrame        {.origin = {self.frame.size.width - 30, 5}, .size = {20, self.frame.size.height - 10}}
#define DDTitleLabelFreame      {.origin = {0, 0}, .size = {self.frame.size.width - 25, self.frame.size.height}}

#define MAX_ROWS_SHOWED     6
#define ROW_HEIGHT          35

#define DDListTableViewOrigin   {-5, self.frame.size.height}
#define DDListTableViewSize(x)  {self.frame.size.width + 10, x}

@interface DropdownView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    int _currentSelction;
    bool _listShowed;
    int _ddListTableViewHeight;
}

- (void)setup;
- (void)setupDropdownButton;
- (void)setupDropdownTableView;

- (void)unsetup;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIImageView *dropdownImageView;

@property (nonatomic, strong) UIButton* backgroundView;
@property (nonatomic, weak) UIView* listTableSuperview;
@property (nonatomic, strong) UITableView* listTableView;
@property (nonatomic, assign) CGRect listTableFrame;

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
    
    CGRect frame1 = DDTitleLabelFreame;
    self.titleLabel.frame = frame1;
    
    CGRect frame2 = DDImageViewFrame;
    self.dropdownImageView.frame = frame2;
    
    self.backgroundView.frame = self.listTableSuperview.frame;
    self.listTableView.frame = self.listTableFrame;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

#pragma mark - Private Methods
- (void)setup
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:   @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    self.listTableFrame = CGRectZero;
    
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _enabledTitle = true;
    _enabledCheckmark = true;
    _data = @[];
    _currentSelction = -1;
    _ddListTableViewHeight = 0;
    
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
    CGRect frame = DDTitleLabelFreame;
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    if (_enabledTitle && _data && _data.count > 0 && _currentSelction >= 0) {
        self.titleLabel.text = _data[_currentSelction];
    }
    else {
        self.titleLabel.text = @"";
    }
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    CGRect frame1 = DDImageViewFrame;
    self.dropdownImageView = [[UIImageView alloc] initWithFrame:frame1];
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_down"];
    self.dropdownImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupDropdownTableView
{
    self.backgroundView = [[UIButton alloc] initWithFrame:self.superview.frame];
    [self.backgroundView addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    
    self.listTableView = [[UITableView alloc] initWithFrame:self.listTableFrame style:UITableViewStylePlain];
    
    CALayer *layer = self.listTableView.layer;
    layer.cornerRadius = 3.0;
    layer.borderWidth = 1.0;
    layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.listTableView.backgroundColor = [UIColor whiteColor];
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    
    [self.backgroundView addSubview:self.listTableView];
}

- (void)unsetup {
    
    [self.listTableView removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    
    [self.titleLabel removeFromSuperview];
    [self.dropdownImageView removeFromSuperview];
    
    [self removeGestureRecognizer:self.tapGestureRecognizer];
    
    self.listTableView = nil;
    self.backgroundView = nil;
    self.titleLabel = nil;
    self.dropdownImageView = nil;
    self.tapGestureRecognizer = nil;
}

#pragma mark - Public Methods
- (void)refresh {
    
    [self unsetup];
    [self setup];
}

- (void)setData:(NSArray *)data {

    @synchronized(self) {
        
        if (data) {
            _data = data;
            
            if (self.enabledTitle && _data.count > 0 && _currentSelction >= 0) {
                
                self.titleLabel.text = _data[_currentSelction];
            }
            
            if (_data.count >= MAX_ROWS_SHOWED) {
                
                _ddListTableViewHeight = MAX_ROWS_SHOWED * ROW_HEIGHT;
            }
            else {
                _ddListTableViewHeight = _data.count * ROW_HEIGHT;
            }
        }
    }
}

- (void)setListBackgroundColor:(UIColor *)listBackgroundColor {

    self.listTableView.backgroundColor = listBackgroundColor;
}

- (void)setDefaultSelection:(int)defaultSelection {
    
    @synchronized(self) {
    
        if (self.enabledTitle && defaultSelection >= 0 && defaultSelection < _data.count) {
            _currentSelction = defaultSelection;
            
            self.titleLabel.text = _data[_currentSelction];
            [self.listTableView reloadData];
        }
    }
}

- (void)showList
{
    _listShowed = true;
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_up"];
    
    self.backgroundView.frame = self.superview.frame;
    [self.backgroundView removeFromSuperview];
    self.listTableSuperview = nil;
    
    UIView* superview = self.superview;
    UIView* subview = self;
    CGPoint tableOrigin = DDListTableViewOrigin;
    
#if DEBUG_DropdownView_HASAN
    NSLog(@"Superview Initial : %@ \n\t %@", superview, subview);
#endif
    
    while (superview) {
        
        CGPoint origin = [superview convertPoint:tableOrigin fromView:self];
        
        if (superview.frame.size.height >= origin.y + _ddListTableViewHeight) {
            break;
        }
        
        subview = superview;
        superview = superview.superview;
        
#if DEBUG_DropdownView_HASAN
        NSLog(@"Superview Intermediate : %@", NSStringFromCGPoint(origin));
        NSLog(@"Superview Intermediate : %@", superview);
#endif
    }
    
    CGPoint origin = DDListTableViewOrigin;
    if (superview) {
        
        origin = [superview convertPoint:origin fromView:self];  // origin in superview's coordinate system
        CGRect frame = {.origin = origin, .size = DDListTableViewSize(_ddListTableViewHeight)};
        
        self.listTableFrame = self.listTableView.frame = frame;
        self.listTableSuperview = superview;
    }
    else {
        
        if (subview == self) {
            subview = self.superview;
        }
        
        origin = [subview convertPoint:origin fromView:self];  // origin in subview's coordinate system
        CGRect frame = {.origin = origin, .size = {self.frame.size.width + 20, subview.frame.size.height - origin.y}};
        
        self.listTableFrame = self.listTableView.frame = frame;
        self.listTableSuperview = subview;
    }
    
#if DEBUG_DropdownView_HASAN
    NSLog(@"Superview Final : %@", self.listTableSuperview);
#endif
    
    if (![self.listTableSuperview.subviews containsObject:self.backgroundView]) {
        [self.listTableSuperview addSubview:self.backgroundView];
        self.backgroundView.frame = self.listTableSuperview.frame;
    }
    [self.listTableView reloadData];
}

- (void)hideList
{
    
    _listShowed = false;
    self.dropdownImageView.image = [UIImage imageNamed:@"drop_down"];
    [self.backgroundView removeFromSuperview];
}

#pragma mark - Actions
- (IBAction)respondToTapGesture:(id)sender
{
    [self.superview endEditing:YES];
    
    if (_listShowed) {
        [self hideList];
    }
    else {
        [self showList];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    if (_listShowed) {
        [self showList];
    }
}

- (IBAction)backgroundTap:(id)sender {

    [self hideList];
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
        cell.textLabel.textColor = self.titleColor;
        cell.backgroundColor = self.listBackgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    
    if (self.enabledCheckmark && indexPath.row == _currentSelction) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)l_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelction = (int)indexPath.row;
    
    if (self.enabledTitle) {
        self.titleLabel.text = self.data[_currentSelction];
    }
    
    [self.delegate dropdownViewActionForSelectedRow:(int)indexPath.row sender:self];
    [l_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self hideList];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownViewActionForSelectedRow:sender:)]) {
        [self.delegate dropdownViewActionForSelectedRow:_currentSelction sender:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
