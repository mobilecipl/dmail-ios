//
//  AlphabetTableViewSectionDataSource.h
//  pium
//
//  Created by Armen Mkrtchian on 01/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "TableViewDataSource.h"

// TODO: change to alphabet table source
@interface AlphabetTableViewSectionDataSource : TableViewDataSource

- (instancetype)initWithItems:(NSArray *)anItems
               cellIdentifier:(NSString *)aCellIdentifier
           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock
      collationStringSelector:(SEL)selector;
@end
