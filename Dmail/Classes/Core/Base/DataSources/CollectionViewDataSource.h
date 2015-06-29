//
//  CollectionViewDataSource.h
//  pium
//
//  Created by Armen Mkrtchian on 14/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectionViewCellBlock)(id cell, id item, BOOL isEditing);

@interface CollectionViewDataSource : NSObject <UICollectionViewDataSource>

// property
@property (nonatomic, strong) NSMutableArray *items;

@property BOOL isEditing;

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(CollectionViewCellBlock)configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (void)removeItem:(id)item;

- (void)removeItemAtIndex:(NSIndexPath *)indexPath;

@end
