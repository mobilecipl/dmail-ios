//
//  CollectionViewSectionDataSource.m
//  mdsave
//
//  Created by Armen on 12/18/14.
//  Copyright (c) 2014 BigBrain. All rights reserved.
//

#import "CollectionViewSectionDataSource.h"
//#import "Util.h"

@implementation CollectionViewSectionDataSource

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    if (indexPath.section < [self.items count]) {
        NSArray *sectionItems = [self.items objectAtIndex:indexPath.section];
        if (indexPath.row < [sectionItems count]) {
            item = sectionItems[(NSUInteger) indexPath.row];
        }
    }
    return item; //[Util objectOrNull:item];
}

//- (void)setItems:(NSArray *)items
//{
//    items = [self partitionObjects:items collationStringSelector:self.collationStringSelector];
//    [super setItems:items];
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return section < self.items.count ? [[self.items objectAtIndex:section] count] : 0;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *reusableview = nil;
//    
//    if (kind == UICollectionElementKindSectionHeader) {
//        UIView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
//        headerView.backgroundColor = [UIColor whiteColor];
//        reusableview = headerView;
//    }
//    
//    if (kind == UICollectionElementKindSectionFooter) {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//        
//        reusableview = footerview;
//    }
//    
//    return reusableview;
//}

@end
