//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewLayoutItem.h"

@implementation BCCollectionViewLayoutItem
@synthesize rowIndex, columnIndex, itemRect, itemIndex, itemContentRect;

+ (id)layoutItem
{
  return [[[self alloc] init] autorelease];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"i:%i r:%i c:%i", (int)itemIndex, (int)rowIndex, (int)columnIndex];
}

@end
