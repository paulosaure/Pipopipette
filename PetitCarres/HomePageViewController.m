//
//  HomePageViewController.m
//  PetitCarres
//
//  Created by Paul Lavoine on 07/02/2016.
//  Copyright © 2016 Paul Lavoine. All rights reserved.
//

#import "HomePageViewController.h"
#import "MapViewController.h"
#import "PlayerManager.h"
#import "GlobalConfigurations.h"
#import "MenuViewController.h"
#import "TutorielViewController.h"
#import "CGUViewController.h"

@interface HomePageViewController ()

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIView *setupView;
@property (weak, nonatomic) IBOutlet UIView *creditView;

@property (weak, nonatomic) IBOutlet UIView *creditButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *creditImageView;

@property (weak, nonatomic) IBOutlet UIImageView *setupImageView;
@property (weak, nonatomic) IBOutlet UIView *setupButtonView;

@property (weak, nonatomic) IBOutlet UIImageView *tutorielImageView;
@property (weak, nonatomic) IBOutlet UIView *tutorielButtonView;

// Data

@end

@implementation HomePageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureUI];
    
    // Gesture Recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(creditAction:)];
    [self.creditButtonView addGestureRecognizer:tapRecognizer];
    
     tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setupAction:)];
    [self.setupButtonView addGestureRecognizer:tapRecognizer];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorielAction:)];
    [self.tutorielButtonView addGestureRecognizer:tapRecognizer];
}

- (void)configureUI
{
    [self.navigationController setNavigationBarHidden:YES];
    
    // Background Color
    self.playView.backgroundColor = GREEN_COLOR;
    self.setupView.backgroundColor = PINK_COLOR;
    self.creditView.backgroundColor = [UIColor whiteColor];
    self.logoView.backgroundColor = [UIColor whiteColor];
    
    // Tint color button
    [self.setupImageView setTintColor:[UIColor whiteColor]];
    [self.creditImageView setTintColor:GREEN_COLOR];
}

#pragma mark - Actions

- (IBAction)startGameAction:(id)sender
{
    [[PlayerManager sharedInstance] setNumberOfPlayers:NB_DEFAULT_PLAYER numberOfBot:NB_DEFAULT_BOT botLevel:BotLevelMedium];
    
    MapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:MapViewControllerID];
    [mapViewController configureMapWithRows:NB_DEFAULT_ROWS columns:NB_DEFAULT_COLUMNS];
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (IBAction)creditAction:(id)sender
{
    CGUViewController *cguViewController = [[CGUViewController alloc] init];
    [self pushViewController:cguViewController title:@"MENTIONS LÉGALES" image:[UIImage imageNamed:@"credit_button"]];
}

- (IBAction)tutorielAction:(id)sender
{
    TutorielViewController *tutorielViewController = [[TutorielViewController alloc] init];
    [self pushViewController:tutorielViewController title:@"TUTORIEL" image:[UIImage imageNamed:@"tutoriel_icon"]];
}

- (IBAction)setupAction:(id)sender
{
    MenuViewController *menuViewController = [[MenuViewController alloc] init];
    [self pushViewController:menuViewController title:@"REGLAGES" image:[UIImage imageNamed:@"setup_button"]];
}

- (void)pushViewController:(ChildViewController *)viewController title:(NSString *)title image:(UIImage *)image
{
    RootViewController *rootViewController = [[RootViewController alloc] initWithTitle:title image:image subView:viewController];
    [self.navigationController pushViewController:rootViewController animated:YES];
}

@end
