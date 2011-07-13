//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewGroup.h"
#import "CHUserDefaults.h"

@implementation BCCollectionViewGroup
@synthesize title, itemRange;
@dynamic isCollapsed;

+ (id)groupWithTitle:(NSString *)title range:(NSRange)range
{
  BCCollectionViewGroup *group = [[BCCollectionViewGroup alloc] init];
  [group setTitle:title];
  [group setItemRange:range];
  return [group autorelease];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@", title, NSStringFromRange(itemRange)];
}

- (void)dealloc
{
  [title release];
  [super dealloc];
}

- (NSString *)defaultsIdentifier
{
  return [NSString stringWithFormat:@"collectionGroup%@Status", title];
}

- (BOOL)isCollapsed
{
  return CHDefaultsBoolForKey([self defaultsIdentifier]);
}

- (void)setIsCollapsed:(BOOL)isCollapsed
{
  CHDefaultsSetBoolForKey(isCollapsed, [self defaultsIdentifier]);
}

@end
