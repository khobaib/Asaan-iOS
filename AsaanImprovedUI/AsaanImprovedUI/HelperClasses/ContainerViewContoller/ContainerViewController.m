//
//  ContainerViewController.m
//  FutureWorld iOS
//
//  Created by Hasan Ibna Akbar on 12/17/13.
//  Copyright (c) 2013 Hasan Ibna Akbar. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@property (assign, nonatomic) BOOL transitionInProgress;

@end

@implementation ContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _transitionInProgress = NO;
    
    if (_segues && _segues.count > 0 && [_segues[_initialIndex] isKindOfClass:[NSString class]]) {
        [self performSegueWithIdentifier:_segues[_initialIndex] sender:nil];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewController:willShowViewController:)]) {
        [self.delegate containerViewController:self willShowViewController:segue.destinationViewController];
    }
    
    // If we're going to the first view controller.
    if (self.childViewControllers.count == 0) {
        
        // If this is the very first time we're loading this we need to do
        // an initial load and not a swap.
        [self addChildViewController:segue.destinationViewController];
        UIView* destView = ((UIViewController *)segue.destinationViewController).view;
        
        destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:destView];
        [segue.destinationViewController didMoveToParentViewController:self];
    }
    else {
        [self swapFromViewController:[self.childViewControllers objectAtIndex:0] toViewController:segue.destinationViewController];
    }
}

- (void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        self.transitionInProgress = NO;
    }];
}

- (void)swapViewControllers:(int)selectedIndex
{
    if (self.transitionInProgress) {
        return;
    }
    
    self.transitionInProgress = YES;
    
    if (_segues && _segues.count > 0 && [_segues[selectedIndex] isKindOfClass:[NSString class]]) {
        [self performSegueWithIdentifier:_segues[selectedIndex] sender:nil];
    }
}

@end
