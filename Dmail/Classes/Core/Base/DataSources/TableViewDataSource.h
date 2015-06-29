//
//  TableViewDataSource.h
//  pium
//
//  Created by Armen Mkrtchian on 25/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellBlock)(id cell, id item);

@interface TableViewDataSource : NSObject <UITableViewDataSource>
// property
@property (nonatomic, strong) NSArray *items;

// method
- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)configureCellBlock;

- (void)setItems:(NSArray *)items;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
