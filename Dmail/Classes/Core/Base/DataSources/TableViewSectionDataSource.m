//
//  TableViewSectionDataSource.m
//  pium
//
//  Created by Armen Mkrtchian on 01/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "TableViewSectionDataSource.h"

@interface TableViewSectionDataSource ()

@end

@implementation TableViewSectionDataSource

//- (instancetype)initWithItems:(NSArray *)anItems
//                     sections:(NSArray *)aSections
//               cellIdentifier:(NSString *)aCellIdentifier
//           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock {
//    
//    self = [super initWithItems:anItems
//                 cellIdentifier:aCellIdentifier
//             configureCellBlock:aConfigureCellBlock];
//    return self;
//}

- (void)setItems:(NSArray *)items
{
    [super setItems:[items mutableCopy]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //sectionForSectionIndexTitleAtIndex: is a bit buggy, but is still useable
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionIndexTitles ? [self.sectionIndexTitles count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section < self.items.count ? [[self.items objectAtIndex:section] count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BOOL showSection = [[self.items objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    return (showSection) ? [self.sectionTitles objectAtIndex:section] : @"-";
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
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
