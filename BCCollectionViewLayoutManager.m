//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionView.h"

@implementation BCCollectionViewLayoutManager

- (id)initWithCollectionView:(BCCollectionView *)aCollectionView
{
  self = [super init];
  if (self) {
    collectionView = aCollectionView;
  }
  return self;
}

- (NSUInteger)numberOfRows
{
  return MAX(1, ceil((float)[[collectionView contentArray] count]/(float)[self numberOfItemsPerRow]));
}

- (NSUInteger)numberOfItemsPerRow
{
  return MAX(1, NSWidth([collectionView frame])/[self cellSize].width);
}

- (NSUInteger)numberOfItemsAtRow:(NSInteger)rowIndex
{
  return [self numberOfItemsPerRow];
}

- (NSSize)cellSize
{
  return [collectionView cellSize];
}

- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p
{
  NSUInteger index = (int)(p.y / [self cellSize].height) * [self numberOfItemsPerRow] + p.x / [self cellSize].width;
  if (index >= [[collectionView contentArray] count])
    return NSNotFound;
  else
    return index;
}

- (NSUInteger)indexOfItemAtPoint:(NSPoint)p
{
  if (p.x > [self cellSize].width * [self numberOfItemsPerRow])
    return NSNotFound;
  
  return [self indexOfItemAtPointOrClosestGuess:p];
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

- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex
{
  NSSize cellSize = [self cellSize];
  NSUInteger rowIndex    = anIndex / [self numberOfItemsPerRow];
  NSUInteger columnIndex = anIndex % [self numberOfItemsPerRow];
  NSInteger gap = (NSWidth([collectionView visibleRect])-[self numberOfItemsPerRow]*cellSize.width)/([self numberOfItemsPerRow]-1);
  return NSMakeRect(columnIndex*(cellSize.width+gap), rowIndex*cellSize.height, cellSize.width, cellSize.height);
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
