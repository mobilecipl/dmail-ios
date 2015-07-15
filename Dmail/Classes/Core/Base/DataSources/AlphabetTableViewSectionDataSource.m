//
//  AlphabetTableViewSectionDataSource.m
//  pium
//
//  Created by Armen Mkrtchian on 01/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "AlphabetTableViewSectionDataSource.h"

@interface AlphabetTableViewSectionDataSource ()
@property SEL collationStringSelector;
@end

@implementation AlphabetTableViewSectionDataSource

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock
      collationStringSelector:(SEL)aCollationStringSelector {
    
    self = [super initWithItems:anItems
                 cellIdentifier:aCellIdentifier
             configureCellBlock:aConfigureCellBlock];
    if (self) {
        _collationStringSelector = aCollationStringSelector;
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    items = [self partitionObjects:items collationStringSelector:self.collationStringSelector];
    [super setItems:[items mutableCopy]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //sectionForSectionIndexTitleAtIndex: is a bit buggy, but is still useable
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //we use sectionTitles and not sections
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section < self.items.count ? [[self.items objectAtIndex:section] count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BOOL showSection = [[self.items objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (instancetype)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    if (indexPath.section < [self.items count]) {
        NSArray *sectionItems = [self.items objectAtIndex:indexPath.section];
        if (indexPath.row < [sectionItems count]) {
            item = sectionItems[(NSUInteger) indexPath.row];
        }
    }
    return item;
}

@end
