//
//  TableViewDataSource.m
//  pium
//
//  Created by Armen Mkrtchian on 25/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "TableViewDataSource.h"

@interface TableViewDataSource ()
//Property
//@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) TableViewCellBlock configureCellBlock;

@end

@implementation TableViewDataSource

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = [anItems mutableCopy];
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    _items = [items mutableCopy];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    if (indexPath.row < [self.items count]) {
        item = self.items[(NSUInteger) indexPath.row];
    }
    return item;
}

- (void)removeItem:(id)item {
    if([self.items containsObject:item]){
        [self.items removeObject:item];
    }
}

- (void)removeItemAtIndex:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count]) {
        [self.items removeObjectAtIndex:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    
    if ([item respondsToSelector:@selector(cellIdentifier)]) {
        self.cellIdentifier = [item cellIdentifier];
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item, indexPath);
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.editing) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //TODO:
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeItemAtIndex:indexPath];
        [tableView reloadData];
        if ([self.delegate respondsToSelector:@selector(deleteMessageWithIndexPath:)]) {
            [self.delegate deleteMessageWithIndexPath:indexPath];
        }
    }
}

@end
