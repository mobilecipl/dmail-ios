//
//  SettingsViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SettingsViewController.h"
#import "EnterPinViewController.h"
#import "EnableTouchIdViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arraytableSectoions;
@property (nonatomic, strong) NSArray *arrayFirstSectionItems;
@property (nonatomic, strong) NSArray *arraySecondSectionItems;
@property (nonatomic, strong) UISwitch *switchControll;
@property (nonatomic, assign) BOOL deviceHasTouch;


@end

@implementation SettingsViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.arraytableSectoions = [NSArray arrayWithObjects:@"SECURITY",@"MORE", nil];
    self.arrayFirstSectionItems = [NSArray arrayWithObjects:@"Touch ID",@"Change pin number",nil];
    self.arraySecondSectionItems = [NSArray arrayWithObjects:@"About",@"FAQ",@"Contact us", nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.navigationController.navigationBar.hidden = YES;
    self.deviceHasTouch = [self isTouchEnabledInDevice];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    if (self.switchControll) {
        self.switchControll.on = [[NSUserDefaults standardUserDefaults] boolForKey:TouchId];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark - Action Methods
- (void)changeSwitchValue:(id)sender {
    
    UISwitch *switch_ = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setBool:switch_.on forKey:TouchId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (switch_.on) {
        [self performSegueWithIdentifier:@"fromSettingsToTouchId" sender:self];
    }
}

- (IBAction)backClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private Methods
- (BOOL)isTouchEnabledInDevice {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 2;
            break;
        case 1:
            rows = 3;
            break;
        default:
            break;
    }
    
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.arraytableSectoions objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else {
        return cell;
    }
    cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
    cell.backgroundColor = [UIColor whiteColor];
    
    // Set the data for this cell:
    switch (indexPath.section) {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [self.arrayFirstSectionItems objectAtIndex:indexPath.row];
            if (indexPath.row == 0) {
                cell.textLabel.textColor = [UIColor blackColor];
                self.switchControll = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 71, 8, 51, 31)];
                self.switchControll.onTintColor = [UIColor colorWithRed:75.0/255.0 green:184.0/255.0 blue:178.0/255.0 alpha:1];
                [self.switchControll addTarget:self action:@selector(changeSwitchValue:) forControlEvents:UIControlEventValueChanged];
                [cell addSubview:self.switchControll];
                self.switchControll.on = [[NSUserDefaults standardUserDefaults] boolForKey:TouchId];
                if (!self.deviceHasTouch) {
                    self.switchControll.on = NO;
                    self.switchControll.enabled = NO;
                }
            }
            else {
                cell.textLabel.textColor = [UIColor colorWithRed:81.0/255.0 green:184.0/255.0 blue:178.0/255.0 alpha:1];
            }
            break;
        case 1:
            cell.textLabel.text = [self.arraySecondSectionItems objectAtIndex:indexPath.row];
            if (indexPath.row == 2) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.textColor = [UIColor colorWithRed:81.0/255.0 green:184.0/255.0 blue:178.0/255.0 alpha:1];
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.textColor = [UIColor blackColor];
            }
            break;
            
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            if(indexPath.row == 1) {
                [self performSegueWithIdentifier:@"fromSettingsToPin" sender:self];
            }
            break;
        case 1:
            if(indexPath.row == 0) {
                
            }
            else if (indexPath.row == 1) {
                
            }
            else {
                
            }
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromSettingsToPin"]) {
        EnterPinViewController * enterPinViewController = (EnterPinViewController *)segue.destinationViewController;
        enterPinViewController.fromSettings = YES;
    }
    else if([segue.identifier isEqualToString:@"fromSettingsToTouchId"]) {
        EnableTouchIdViewController * enableTouchIdViewController = (EnableTouchIdViewController *)segue.destinationViewController;
        enableTouchIdViewController.fromSettings = YES;
    }
}

@end
