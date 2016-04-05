//
//  MenuViewController.m
//  PetitCarres
//
//  Created by Paul Lavoine on 07/12/2015.
//  Copyright © 2015 Paul Lavoine. All rights reserved.
//

#import "MenuViewController.h"
#import "MapViewController.h"
#import "PlayerManager.h"
#import "BarButton.h"
#import "CustomStepper.h"
#import "GlobalConfigurations.h"

#define NUMBER_PLAYER_LABEL @"Nombre de joueur"
#define NUMBER_BOT_LABEL @"Nombre de Bot"
#define DEFAULT_LEVEL   1

#define COLUMN_LABEL @"NB COLONNE : %ld"
#define ROW_LABEL @"NB LIGNE : %ld"
#define LEVEL_LABEL @"NIVEAU : %ld"


@interface MenuViewController () <UINavigationControllerDelegate, CustomStepperDelegate>

// Outlets
@property (weak, nonatomic) IBOutlet UILabel *nbPlayerLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *secondPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthPlayerButton;

@property (weak, nonatomic) IBOutlet UILabel *nbBotLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBotButton;
@property (weak, nonatomic) IBOutlet UIButton *secondBotButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdBotButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthBotButton;

@property (weak, nonatomic) IBOutlet UILabel *nbColumnLabel;
@property (weak, nonatomic) IBOutlet CustomStepper *nbColumnStepper;
@property (weak, nonatomic) IBOutlet UILabel *nbRowLabel;
@property (weak, nonatomic) IBOutlet CustomStepper *nbRowStepper;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet CustomStepper *levelStepper;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

// Data
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSArray *realPlayers;
@property (nonatomic, strong) NSArray *botPlayers;
@property (nonatomic, assign) BOOL reachMaxPlayers;
@property (nonatomic, assign) NSInteger nbColumnMax;
@property (nonatomic, assign) NSInteger nbRowMax;

// Data
@property (nonatomic, strong) GlobalConfigurations *configurations;
//@property (nonatomic, strong) UIView *colorSelectedButtonView;
@property (nonatomic, assign) BOOL alreadyAppear;

@end

@implementation MenuViewController

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super initWithNibName:@"MenuViewController" bundle:nil])
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.configurations = [GlobalConfigurations sharedInstance];
    [self.levelStepper setValue:DEFAULT_LEVEL];
    self.navigationController.delegate = self;
    self.nbColumnStepper.delegate = self;
    self.nbRowStepper.delegate = self;
    self.levelStepper.delegate = self;
    
    self.players = @[self.firstPlayerButton, self.firstBotButton, self.secondBotButton, self.secondPlayerButton, self.thirdBotButton, self.thirdPlayerButton, self.fourthBotButton, self.fourthPlayerButton];
    
    self.realPlayers = @[self.firstPlayerButton, self.secondPlayerButton, self.thirdPlayerButton, self.fourthPlayerButton];
    
    self.botPlayers = @[self.firstBotButton, self.secondBotButton, self.thirdBotButton, self.fourthBotButton];
    
    [self configureDefaultMenu];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    int minSpaceBorder = (MIN_LARGER_TOUCH - BAR_BUTTON_SPACE) / 2;
    self.nbColumnMax = [self limitNumberOfSquarre:10
                                highSideBarButton:SIZE_PIECE
                                            space:BAR_BUTTON_SPACE
                                   minSpaceBorder:minSpaceBorder
                                         widthMax:self.rootParentViewController.view.frame.size.width];
    
    self.nbRowMax = [self limitNumberOfSquarre:10
                             highSideBarButton:SIZE_PIECE
                                         space:BAR_BUTTON_SPACE
                                minSpaceBorder:minSpaceBorder
                                      widthMax:self.rootParentViewController.view.frame.size.height];
}

- (void)configureDefaultMenu
{
    // Init game start button
    self.startGameButton.backgroundColor = GREEN_COLOR;
    self.startGameButton.titleLabel.text = @"JOUER";
    self.startGameButton.titleLabel.textColor = [UIColor whiteColor];
    
    // Init Stepper
    [self.nbPlayerLabel setText:[NUMBER_PLAYER_LABEL uppercaseString]];
    [self.nbBotLabel setText:[NUMBER_BOT_LABEL uppercaseString]];
    [self initPlayers];
    
    // Init Picker View
    [self.nbRowStepper setValue:NB_DEFAULT_ROWS - 1];
    [self.nbRowLabel setText:[NSString stringWithFormat:ROW_LABEL, (long)NB_DEFAULT_ROWS - 1]];
    [self.nbColumnStepper setValue:NB_DEFAULT_COLUMNS - 1];
    [self.nbColumnLabel setText:[NSString stringWithFormat:COLUMN_LABEL, (long)NB_DEFAULT_COLUMNS - 1]];
    
    // Init level button
    [self.levelStepper setValue:DEFAULT_LEVEL];
    [self.levelLabel setText:[NSString stringWithFormat:LEVEL_LABEL, (long)DEFAULT_LEVEL]];
}

- (void)initPlayers
{
    [self selectButton:self.firstBotButton isSelected:YES];
    [self selectButton:self.firstPlayerButton isSelected:YES];
    self.firstPlayerButton.userInteractionEnabled = NO;
    [self selectButton:self.secondPlayerButton isSelected:NO];
    [self selectButton:self.secondBotButton isSelected:NO];
    [self selectButton:self.thirdPlayerButton isSelected:NO];
    [self selectButton:self.thirdBotButton isSelected:NO];
    [self selectButton:self.fourthPlayerButton isSelected:NO];
    [self selectButton:self.fourthBotButton isSelected:NO];
}

#pragma mark - Actions

- (IBAction)startGame:(id)sender
{
    BotLevel level = [self selectedLevel];
    self.configurations.nbPlayer = [self computeNbPlayers:self.realPlayers];
    self.configurations.nbBot = [self computeNbPlayers:self.botPlayers];
    [[PlayerManager sharedInstance] setNumberOfPlayers:self.configurations.nbPlayer numberOfBot:self.configurations.nbBot botLevel:level];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MapViewController *mapViewController = [mainStoryboard instantiateViewControllerWithIdentifier:MapViewControllerID];
    [mapViewController configureMapWithRows:self.nbRowStepper.value columns:self.nbColumnStepper.value];
    
    [self.rootParentViewController pushViewController:mapViewController];
}

- (IBAction)valueChanged:(UIStepper *)sender
{
    NSInteger maxValue = 0;
    NSInteger minValue = 0;
    UILabel *label;
    NSString *string;
    
    if (sender == self.nbColumnStepper)
    {
        maxValue = self.nbColumnMax;
        string = COLUMN_LABEL;
        label = self.nbColumnLabel;
    }
    else if (sender == self.nbRowStepper)
    {
        maxValue = self.nbRowMax;
        string = ROW_LABEL;
        label = self.nbRowLabel;
    }
    else if (sender == self.levelStepper)
    {
        maxValue = 4;
        string = LEVEL_LABEL;
        label = self.levelLabel;
    }
    else
    {
        NSLog(@"stepper not found");
    }
    
    
    if (sender.value + 1 > maxValue)
    {
        sender.value = maxValue;
    }
    else if (sender.value - 1 <= minValue)
    {
        sender.value = minValue + 1;
    }
    
    [label setText:[NSString stringWithFormat:string, [@(sender.value) integerValue]]];
}

#pragma mark - Actions

- (IBAction)selectPlayer:(UIButton *)sender
{
    if (!sender.isSelected && self.reachMaxPlayers)
        return;
    
    [self selectButton:sender isSelected:!sender.selected];
    [self isFullPlayerSelected];
}

#pragma mark - Utils

- (void)selectButton:(UIButton *)button isSelected:(BOOL)isSelected
{
    button.selected = isSelected;
    button.tintColor = button.selected ? GREEN_COLOR : [UIColor blackColor];
}

- (BOOL)isFullPlayerSelected
{
    NSInteger nbPlayers = 0;
    for (UIButton *player in self.players)
    {
        if (player.isSelected)
        {
            nbPlayers ++;
            if (nbPlayers >= NB_MAX_PLAYER)
            {
                self.reachMaxPlayers = YES;
                [self colorPlayersNotSelected:YES];
                return YES;
            }
        }
    }
    
    self.reachMaxPlayers = NO;
    [self colorPlayersNotSelected:NO];
    return NO;
}

- (void)colorPlayersNotSelected:(BOOL)shouldColor
{
    for (UIButton *player in self.players)
    {
        if (!player.isSelected)
        {
            player.tintColor = shouldColor ? [UIColor redColor] : [UIColor blackColor];
        }
        else
        {
            player.tintColor = GREEN_COLOR;
        }
    }
}

- (NSInteger)computeNbPlayers:(NSArray *)players
{
    NSInteger nbPlayer = 0;
    for (UIButton *player in players)
    {
        if (player.isSelected)
        {
            nbPlayer++;
        }
    }
    return nbPlayer;
}

- (BotLevel)selectedLevel
{
    if (self.levelStepper.value == 1)
    {
        return BotLevelEasy;
    }
    else if (self.levelStepper.value == 2)
    {
        return BotLevelMedium;
    }
    else if (self.levelStepper.value == 3)
    {
        return BotLevelDifficult;
    }
    else
    {
        return BotLevelExtreme;
    }
}

- (NSInteger)limitNumberOfSquarre:(NSInteger)cases highSideBarButton:(NSInteger)highSideBarButton space:(NSInteger)space minSpaceBorder:(NSInteger)minSpaceBorder widthMax:(NSInteger)widthMax
{
    NSInteger nbCaseAvailable = cases;
    while (widthMax < ((nbCaseAvailable*highSideBarButton) + (space*(nbCaseAvailable+1) + 2*minSpaceBorder)))
    {
        nbCaseAvailable --;
    }
    
    return nbCaseAvailable;
}

@end
