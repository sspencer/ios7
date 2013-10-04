//
//  DynamicSandwichViewController.m
//  SandwichFlow
//
//  Created by Steve Spencer on 10/3/13.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "DynamicSandwichViewController.h"
#import "SandwichViewController.h"
#import "AppDelegate.h"

@interface DynamicSandwichViewController ()

@end

@implementation DynamicSandwichViewController
{
    NSMutableArray *_views;
    UIGravityBehavior *_gravity;
    UIDynamicAnimator *_animator;
    CGPoint _previousTouchPoint;
    BOOL _draggingView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Background image
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background-LowerLayer.png"]];
    [self.view addSubview:backgroundImageView];

    // Header logo
    UIImageView* header = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sarnie.png"]];
    header.center = CGPointMake(220, 190);
    [self.view addSubview:header];

    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _gravity = [[UIGravityBehavior alloc] init];
    [_animator addBehavior:_gravity];
    _gravity.magnitude = 4.0f;

    // add recipes
    _views = [NSMutableArray new];
    float offset = 250.0f;
    for (NSDictionary* sandwich in [self sandwiches]) {
        [_views addObject:[self addRecipeAtOffset:offset forSandwich:sandwich]];
        offset -= 50.0f;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)sandwiches
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.sandwiches;
}

- (UIView*)addRecipeAtOffset:(float)offset forSandwich:(NSDictionary*)sandwich
{
    CGRect frameForView = CGRectOffset(self.view.bounds, 0.0, self.view.bounds.size.height - offset);

    // 1. create the view controller
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SandwichViewController* viewController = [mystoryboard instantiateViewControllerWithIdentifier:@"SandwichVC"];

    // 2. set the frame and provide some data
    UIView* view = viewController.view;
    view.frame = frameForView;
    viewController.sandwich = sandwich;

    // 3. add as a child
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];

    // gesture recognizer
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [viewController.view addGestureRecognizer:pan];

    // create collision
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[view]];
    [_animator addBehavior:collision];

    // lower boundary where tab rests
    float boundary = view.frame.origin.y + view.frame.size.height + 1;
    CGPoint boundaryStart = CGPointMake(0.0, boundary);
    CGPoint boundaryEnd = CGPointMake(self.view.bounds.size.width, boundary);
    [collision addBoundaryWithIdentifier:@1 fromPoint:boundaryStart toPoint:boundaryEnd];

    [_gravity addItem:view];

    return view;
}

- (void)handlePan:(UIPanGestureRecognizer*)gesture {
    CGPoint touchPoint = [gesture locationInView:self.view];
    UIView* draggedView = gesture.view;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 1. was the pan initiated from the upper part of the recipe?
        CGPoint dragStartLocation = [gesture locationInView:draggedView];
        if (dragStartLocation.y < 200.0f) {
            _draggingView = YES;
            _previousTouchPoint = touchPoint;
        }

    } else if (gesture.state == UIGestureRecognizerStateChanged && _draggingView) {
        // 2. handle dragging
        float yOffset = _previousTouchPoint.y - touchPoint.y;
        gesture.view.center = CGPointMake(draggedView.center.x,
                                          draggedView.center.y - yOffset);
        _previousTouchPoint = touchPoint;

    } else if (gesture.state == UIGestureRecognizerStateEnded && _draggingView) {
        // 3. the gesture has ended
        [_animator updateItemUsingCurrentState:draggedView];
        _draggingView = NO;
    }
}
@end
