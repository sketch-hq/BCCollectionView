//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@interface BCCollectionViewItemLayout : NSObject
{
  NSInteger rowIndex, columnIndex, itemIndex;
  NSRect itemRect;
}
@property NSInteger rowIndex, columnIndex, itemIndex;
@property NSRect itemRect;
+ (id)layoutItem;
@end
