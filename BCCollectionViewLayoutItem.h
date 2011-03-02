//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@interface BCCollectionViewLayoutItem : NSObject
{
  NSInteger rowIndex, columnIndex, itemIndex;
  NSRect itemRect, itemContentRect;
}
@property (nonatomic) NSInteger rowIndex, columnIndex, itemIndex;
@property (nonatomic) NSRect itemRect, itemContentRect;
+ (id)layoutItem;
@end
