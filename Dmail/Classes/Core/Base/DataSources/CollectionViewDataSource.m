//
//  CollectionViewDataSource.m
//  pium
//
//  Created by Armen Mkrtchian on 14/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "CollectionViewDataSource.h"

// #import "InboxBasicCollectionViewCell.h"

//#import "InboxItemViewModel.h"

@interface CollectionViewDataSource ()

//Property
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) CollectionViewCellBlock configureCellBlock;

@end

@implementation CollectionViewDataSource

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(CollectionViewCellBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        self.items = [anItems mutableCopy];
        self.cellIdentifier = aCellIdentifier;
        self.configureCellBlock = [aConfigureCellBlock copy];
        _isEditing = NO;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    id item = [self itemAtIndexPath:indexPath];
    
    if ([item respondsToSelector:@selector(cellIdentifier)]) {
        self.cellIdentifier = [item cellIdentifier];
    }
    
    id cell  = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                         forIndexPath:indexPath];
    
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item, self.isEditing);
    }
    
    return cell;
}

@end
