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
    numberOfRows = -1;
  }
  return self;
}

- (void)willReload
{
  numberOfRows = -1;
}

#pragma mark -
#pragma mark Primitives

- (NSUInteger)numberOfRows
{
  if (numberOfRows == -1) {
    NSInteger leftOver = [[collectionView contentArray] count];
    numberOfRows = 0;
    while (leftOver > 0) {
      leftOver -= [self numberOfItemsAtRow:numberOfRows];
      numberOfRows++;
    }
  }
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


- (NSUInteger)rowOfItemAtIndex:(NSInteger)anIndex
{
  NSInteger rowIndex = 0;
  while (anIndex >= [self numberOfItemsAtRow:rowIndex]) {
    anIndex -= [self numberOfItemsAtRow:rowIndex];
    rowIndex++;
  }
  return rowIndex;
}

- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p
{
  NSUInteger rowIndex = (int)p.y / [self cellSize].height;
  
  NSInteger rowFirstIndex = 0;
  for (NSInteger i=0; i<rowIndex; i++)
    rowFirstIndex += [self numberOfItemsAtRow:i];
  
  NSInteger gap = (NSWidth([collectionView visibleRect])-[self numberOfItemsAtRow:rowIndex]*[self cellSize].width)/([self numberOfItemsAtRow:rowIndex]-1);
  NSUInteger index = rowFirstIndex + MIN([self numberOfItemsAtRow:rowIndex]-1, p.x / ([self cellSize].width+gap));
  if (index >= [[collectionView contentArray] count])
    return NSNotFound;
  else
    return index;
}

- (NSUInteger)indexOfItemAtPoint:(NSPoint)p
{
  NSUInteger rowIndex = (int)p.y / [self cellSize].height;
  NSInteger gap = (NSWidth([collectionView visibleRect])-[self numberOfItemsAtRow:rowIndex]*[self cellSize].width)/([self numberOfItemsAtRow:rowIndex]-1);
  if (p.x > ([self cellSize].width+gap) * [self numberOfItemsAtRow:rowIndex])
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
  
  NSInteger rowIndex    = 0;
  NSInteger columnIndex = anIndex;
  while (columnIndex >= [self numberOfItemsAtRow:rowIndex]) {
    columnIndex -= [self numberOfItemsAtRow:rowIndex];
    rowIndex++;
  }
  NSInteger gap = (NSWidth([collectionView visibleRect])-[self numberOfItemsAtRow:rowIndex]*cellSize.width)/([self numberOfItemsAtRow:rowIndex]-1);
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
