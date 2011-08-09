//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView+Keyboard.h"
#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionViewLayoutItem.h"

@implementation BCCollectionView (BCCollectionView_Keyboard)

- (void)keyDown:(NSEvent *)theEvent
{
  [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)clearAccumulatedBuffer
{
  self.accumulatedKeyStrokes = @"";
}

- (void)insertText:(id)aString
{
  if ([delegate respondsToSelector:@selector(collectionView:nameOfItem:startsWith:)]) {
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(clearAccumulatedBuffer) target:self argument:nil];
    [self performSelector:@selector(clearAccumulatedBuffer) withObject:nil afterDelay:1.0];
    
    self.accumulatedKeyStrokes = [[accumulatedKeyStrokes stringByAppendingString:aString] lowercaseString];
    
    NSInteger firstIndex = [contentArray indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
      return [delegate collectionView:self nameOfItem:obj startsWith:accumulatedKeyStrokes];
    }];
    if (firstIndex != NSNotFound) {
      [self deselectAllItems];
      [self selectItemAtIndex:firstIndex];
      
      if (NSHeight([self frame]) > NSHeight([self visibleRect])) {
        NSScrollView *scrollView = [self enclosingScrollView];
        NSClipView *clipView     = [[self enclosingScrollView] contentView];
        
        [clipView scrollToPoint:NSMakePoint(0, MIN(NSHeight([self frame])-NSHeight([self visibleRect]),[layoutManager rectOfItemAtIndex:firstIndex].origin.y))];
        [scrollView reflectScrolledClipView:clipView];
      }
    }
  }
}

#pragma mark Helper Methods

- (void)simpleSelectItemAtIndex:(NSUInteger)anIndex
{
  if (anIndex != NSNotFound) {
    [self deselectAllItems];
    [self selectItemAtIndex:anIndex];
    [self scrollRectToVisible:[layoutManager rectOfItemAtIndex:anIndex]];
  }
}

- (void)simpleExtendSelectionRange:(NSRange)range newIndex:(NSUInteger)newIndex
{
  if (newIndex != NSNotFound) {
    if ([selectionIndexes containsIndex:newIndex])
      [self deselectItemsAtIndexes:[[NSIndexSet indexSetWithIndexesInRange:range] indexSetByRemovingIndex:newIndex]];
    else
      [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    lastSelectionIndex = newIndex;
    [self scrollRectToVisible:[layoutManager rectOfItemAtIndex:newIndex]];
  }
}

#pragma mark Arrow Keys

- (void)moveLeft:(id)sender
{
  if (lastSelectionIndex > 0)
    [self simpleSelectItemAtIndex:lastSelectionIndex-1];
}

- (void)moveLeftAndModifySelection:(id)sender
{
  if (lastSelectionIndex > 0) {
    NSUInteger newIndex = MAX(0, lastSelectionIndex-1);
    [self simpleExtendSelectionRange:NSMakeRange(newIndex, 2) newIndex:newIndex];
  }
}

- (void)moveRight:(id)sender
{
  [self simpleSelectItemAtIndex:MIN([[self contentArray] count]-1, lastSelectionIndex+1)];
}

- (void)moveRightAndModifySelection:(id)sender
{
  NSUInteger newIndex = MIN([[self contentArray] count]-1, lastSelectionIndex+1);
  [self simpleExtendSelectionRange:NSMakeRange(lastSelectionIndex, 2) newIndex:newIndex];
}

- (void)moveUp:(id)sender
{
  NSPoint position = [layoutManager rowAndColumnPositionOfItemAtIndex:lastSelectionIndex];
  [self simpleSelectItemAtIndex:[layoutManager indexOfItemAtRow:position.y-1 column:position.x]];
}

- (void)moveUpAndModifySelection:(id)sender
{
  NSPoint position = [layoutManager rowAndColumnPositionOfItemAtIndex:lastSelectionIndex];
  NSUInteger newIndex = [layoutManager indexOfItemAtRow:position.y-1 column:position.x];
  if (newIndex == NSNotFound)
    newIndex = 0;
  
  NSRange range = NSMakeRange(newIndex, lastSelectionIndex-newIndex);
  if ([selectionIndexes containsIndex:newIndex])
    range.location++;
  
  [self simpleExtendSelectionRange:range newIndex:newIndex];
}

- (void)moveDown:(id)sender
{
  NSPoint position = [layoutManager rowAndColumnPositionOfItemAtIndex:lastSelectionIndex];
  [self simpleSelectItemAtIndex:[layoutManager indexOfItemAtRow:position.y+1 column:position.x]];
}

- (void)moveDownAndModifySelection:(id)sender
{
  NSPoint position    = [layoutManager rowAndColumnPositionOfItemAtIndex:lastSelectionIndex];
  NSUInteger newIndex = [layoutManager indexOfItemAtRow:position.y+1 column:position.x];
  if (newIndex == NSNotFound)
    newIndex = [contentArray count]-1;
  
  NSRange range = NSMakeRange(lastSelectionIndex, newIndex-lastSelectionIndex);
  if (![selectionIndexes containsIndex:newIndex])
    range.length++;
  
  [self simpleExtendSelectionRange:range newIndex:newIndex];
}

#pragma mark Deleting

- (void)deleteBackward:(id)sender
{
  if ([delegate respondsToSelector:@selector(collectionView:deleteItemsAtIndexes:)])
    [delegate collectionView:self deleteItemsAtIndexes:selectionIndexes];
}

- (void)deleteForward:(id)sender
{
  [self deleteBackward:sender];
}

@end

@implementation NSIndexSet (BCCollectionView_IndexSet)
- (NSIndexSet *)indexSetByRemovingIndex:(NSUInteger)index
{
  return [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
    return index != idx;
  }];
}
@end