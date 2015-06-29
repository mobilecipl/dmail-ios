//
//  TableViewSectionDataSource.h
//  pium
//
//  Created by Armen Mkrtchian on 01/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "TableViewDataSource.h"

// TODO: change to alphabet table source
@interface TableViewSectionDataSource : TableViewDataSource

// property
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionIndexTitles;

//- (instancetype)initWithItems:(NSArray *)anItems
//                sectionTitles:(NSArray *)aSections
//               cellIdentifier:(NSString *)aCellIdentifier
//           configureCellBlock:(TableViewCellBlock)aConfigureCellBlock;
@end
