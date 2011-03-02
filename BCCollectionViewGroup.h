//  Created by Pieter Omvlee on 01/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@interface BCCollectionViewGroup : NSObject
{
  NSString *title;
  NSRange itemRange;
  BOOL isCollapsed;
}
+ (id)groupWithTitle:(NSString *)title range:(NSRange)range;
@property (copy) NSString *title;
@property NSRange itemRange;
@property (setter=setCollapsed:) BOOL isCollapsed;

@end
