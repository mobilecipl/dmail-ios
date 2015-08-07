//
//  InboxCell.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageCell.h"

extern NSString *const InboxCellIdentifier;

@protocol InboxCellDelegate <NSObject>

- (void)messageDelete:(id)cell;
- (void)messageArchive:(id)cell;
- (void)messageUnread:(id)cell;
- (void)panelMovedOnRight:(id)cell;

@end


@interface InboxCell : MessageCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeadingMainView;
@property (nonatomic, assign) id<InboxCellDelegate> delegate;
@property (nonatomic, assign) NSInteger row;

- (void)movePanelToLeft;

@end
