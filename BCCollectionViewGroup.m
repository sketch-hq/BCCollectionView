//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewGroup.h"

@implementation BCCollectionViewGroup
@synthesize title, itemRange, isCollapsed;

+ (id)groupWithTitle:(NSString *)title range:(NSRange)range
{
  BCCollectionViewGroup *group = [[BCCollectionViewGroup alloc] init];
  [group setTitle:title];
  [group setItemRange:range];
  return [group autorelease];
}

- (void)dealloc
{
  [title release];
  [super dealloc];
}

@end
