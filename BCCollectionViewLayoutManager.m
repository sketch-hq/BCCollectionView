//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionView.h"
#import "BCCollectionViewGroup.h"
#import "BCCollectionViewItemLayout.h"

@implementation BCCollectionViewLayoutManager
@synthesize itemLayouts;

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
  numberOfRows = 0;
  [queue cancelAllOperations];
  [queue addOperationWithBlock:^{
    [itemLayouts removeAllObjects];
    NSInteger x = 0;
    NSInteger y = 0;
    NSUInteger colIndex = 0;
    
    NSEnumerator *groupEnum = [[collectionView groups] objectEnumerator];
    BCCollectionViewGroup *group = [groupEnum nextObject];
    NSSize cellSize = [self cellSize];
    NSUInteger count = [[collectionView contentArray] count];
    for (NSInteger i=0; i<count; i++) {
      if (group && [group itemRange].location == i) {
        if (x != 0) {
          numberOfRows++;
          colIndex = 0;
          y += cellSize.height;
        }
        y += [collectionView groupHeaderHeight];
        x = 0;
      }
      BCCollectionViewItemLayout *item = [BCCollectionViewItemLayout layoutItem];
      [item setItemIndex:i];
      if (![group isCollapsed]) {
        if (x + cellSize.width > NSMaxX([collectionView visibleRect])) {
          numberOfRows++;
          colIndex = 0;
          y += cellSize.height;
          x  = 0;
        }
        [item setColumnIndex:colIndex];
        [item setItemRect:NSMakeRect(x, y, cellSize.width, cellSize.height)];
        x += cellSize.width;
        colIndex++;
      } else {
        [item setItemRect:NSMakeRect(x, y, 0, 0)];
      }
      [item setRowIndex:numberOfRows];
      [itemLayouts addObject:item];
      
      if ([group itemRange].location + [group itemRange].length-1 == i)
        group = [groupEnum nextObject];
    }
    numberOfRows = MAX(numberOfRows, [[collectionView groups] count]);
    if ([[collectionView contentArray] count] > 0 && numberOfRows == -1)
      numberOfRows = 1;
    dispatch_async(dispatch_get_main_queue(), completionBlock);
  }];
}

- (void)dealloc
{
  [itemLayouts release];
  [queue release];
  [super dealloc];
}

#pragma mark -
#pragma mark Primitives

- (NSUInteger)numberOfRows
{
  return numberOfRows;
}

- (NSUInteger)maximumNumberOfItemsPerRow
{
  return MAX(1, [collectionView frame].size.width/[self cellSize].width);
}

- (NSSize)cellSize
{
  return [collectionView cellSize];
}

#pragma mark -
#pragma mark Rows and Columns

- (NSPoint)rowAndColumnPositionOfItemAtIndex:(NSUInteger)anIndex
{
  BCCollectionViewItemLayout *itemLayout = [itemLayouts objectAtIndex:anIndex];
  return NSMakePoint(itemLayout.columnIndex, itemLayout.rowIndex);
}

- (NSUInteger)indexOfItemAtRow:(NSUInteger)rowIndex column:(NSUInteger)colIndex
{
  __block NSUInteger index = NSNotFound;
  [itemLayouts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id item, NSUInteger idx, BOOL *stop) {
    if ([item rowIndex] == rowIndex && [item columnIndex] == colIndex) {
      index = [item itemIndex];
      *stop = YES;
    }
  }];
  return index;
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
