//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionViewItemLayout.h"
#import "BCCollectionViewGroup.h"
#import "BCCollectionView.h"

@implementation BCCollectionViewLayoutManager
@synthesize groups;

- (id)initWithCollectionView:(BCCollectionView *)aCollectionView
{
  self = [super init];
  if (self) {
    collectionView = aCollectionView;
    itemLayouts    = [[NSMutableArray alloc] init];
    numberOfRows   = -1;
    queue          = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    
  }
  return self;
}

- (void)reloadWithCompletionBlock:(dispatch_block_t)completionBlock
{
  numberOfRows = -1;
  [queue cancelAllOperations];
  [queue addOperationWithBlock:^{
    [itemLayouts removeAllObjects];
    NSInteger x = 0;
    NSInteger y = 0;
    
    NSEnumerator *groupEnum = [groups objectEnumerator];
    BCCollectionViewGroup *group = [groupEnum nextObject];
    NSSize cellSize = [self cellSize];
    NSUInteger count = [[collectionView contentArray] count];
    for (NSInteger i=0; i<count; i++) {
      if (group && [group itemRange].location == i) {
        if (x != 0) {
          numberOfRows++;
          y += cellSize.height;
        }
        y += BCCollectionViewGroupHeight;
        x = 0;
      }
      BCCollectionViewItemLayout *item = [BCCollectionViewItemLayout layoutItem];
      [item setItemIndex:i];
      [item setRowIndex:numberOfRows];
      if (![group isCollapsed]) {
        if (x + cellSize.width > NSMaxX([collectionView visibleRect])) {
          numberOfRows++;
          y += cellSize.height;
          x  = 0;
        }
        [item setItemRect:NSMakeRect(x, y, cellSize.width, cellSize.height)];
        x += cellSize.width;
      } else {
        [item setItemRect:NSMakeRect(x, y, 0, 0)];
      }
      [itemLayouts addObject:item];
      
      if ([group itemRange].location + [group itemRange].length == i)
        group = [groupEnum nextObject];
    }
    dispatch_async(dispatch_get_main_queue(), completionBlock);
  }];
}

- (void)dealloc
{
  [itemLayouts release];
  [groups release];
  [queue release];
  [super dealloc];
}

#pragma mark -
#pragma mark Primitives

- (NSUInteger)numberOfRows
{
  return numberOfRows;
}

- (NSUInteger)numberOfItemsAtRow:(NSInteger)rowIndex
{
  return MAX(1, [collectionView frame].size.width/[self cellSize].width);
}

- (NSSize)cellSize
{
  return [collectionView cellSize];
}

#pragma mark -
#pragma mark From Point to Index

- (NSUInteger)indexOfItemAtPoint:(NSPoint)p
{
  NSInteger count = [itemLayouts count];
  for (NSInteger i=0; i<count; i++)
    if (NSPointInRect(p, [[itemLayouts objectAtIndex:i] itemRect]))
      return i;
  return NSNotFound;
}

- (NSUInteger)indexOfItemContentRectAtPoint:(NSPoint)p
{
  NSUInteger index = [self indexOfItemAtPoint:p];
  if (index != NSNotFound) {
    if (NSPointInRect(p, [self contentRectOfItemAtIndex:index]))
      return index;
    else
      return NSNotFound;
  }
  return index;
}

#pragma mark -
#pragma mark From Index to Rect

- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex
{
  if (anIndex < [itemLayouts count])
    return [[itemLayouts objectAtIndex:anIndex] itemRect];
  else
    return NSMakeRect(0, 0, [self cellSize].width, [self cellSize].height);
}

- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex
{
  NSRect rect = [self rectOfItemAtIndex:anIndex];
  if ([[collectionView delegate] respondsToSelector:@selector(insetMarginForSelectingItemsInCollectionView:)]) {
    NSSize inset = [[collectionView delegate] insetMarginForSelectingItemsInCollectionView:collectionView];
    return NSInsetRect(rect, inset.width, inset.height);
  } else
    return rect;
}
@end
