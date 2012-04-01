//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionView.h"
#import "BCCollectionViewGroup.h"
#import "BCCollectionViewLayoutItem.h"

@implementation BCCollectionViewLayoutManager
@synthesize itemLayouts;

- (id)initWithCollectionView:(BCCollectionView *)aCollectionView
{
  self = [super init];
  if (self) {
    collectionView = aCollectionView;
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
  }
  return self;
}

- (void)cancelItemEnumerator
{
  [queue cancelAllOperations];
}

- (void)enumerateItems:(BCCollectionViewLayoutOperationIterator)itemIterator completionBlock:(dispatch_block_t)completionBlock
{
  BCCollectionViewLayoutOperation *operation = [[BCCollectionViewLayoutOperation alloc] init];
  [operation setCollectionView:collectionView];
  [operation setLayoutCallBack:itemIterator];
  [operation setLayoutCompletionBlock:completionBlock];
  
// if ([queue operationCount] > 10)
    [queue cancelAllOperations];
  [queue addOperation:[operation autorelease]];
}

- (void)dealloc
{
  [itemLayouts release];
  [queue release];
  [super dealloc];
}

#pragma mark -
#pragma mark Primitives

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
  if ([itemLayouts count] > anIndex) {
    BCCollectionViewLayoutItem *itemLayout = [itemLayouts objectAtIndex:anIndex];
    return NSMakePoint(itemLayout.columnIndex, itemLayout.rowIndex);
  } else
    return NSZeroPoint;
}

- (NSUInteger)indexOfItemAtRow:(NSUInteger)rowIndex column:(NSUInteger)colIndex
{
  __block NSUInteger index = NSNotFound;
  [itemLayouts enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(BCCollectionViewLayoutItem *item, NSUInteger idx, BOOL *stop) {
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
    return NSZeroRect;
}

- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex
{
  if (anIndex < [itemLayouts count])
    return [[itemLayouts objectAtIndex:anIndex] itemContentRect];
  else
    return NSZeroRect;
}
@end
