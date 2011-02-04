//
//  BCCollectionView+Keyboard.m
//  Fontcase
//
//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import "BCCollectionView+Keyboard.h"

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
        
        [clipView scrollToPoint:NSMakePoint(0, MIN(NSHeight([self frame])-NSHeight([self visibleRect]),[self rectOfItemAtIndex:firstIndex].origin.y))];
        [scrollView reflectScrolledClipView:clipView];
      }
    }
  }
}

- (void)moveLeft:(id)sender
{
  NSUInteger index = lastSelectionIndex;
  if (index % [self numberOfItemsPerRow] != 0) {
    [self deselectAllItems];
    NSUInteger newIndex = index-1;
    [self selectItemAtIndex:newIndex];
    [self scrollRectToVisible:[self rectOfItemAtIndex:newIndex]];
  }
}

- (void)moveLeftAndModifySelection:(id)sender
{
  if (lastSelectionIndex % [self numberOfItemsPerRow] != 0) {
    NSUInteger index = lastSelectionIndex-1;
    if ([selectionIndexes containsIndex:index])
      [self deselectItemAtIndex:lastSelectionIndex];
    else
      [self selectItemAtIndex:index];
    lastSelectionIndex = index;
    [self scrollRectToVisible:[self rectOfItemAtIndex:index]];
  }
}

- (void)moveRight:(id)sender
{
  NSUInteger index = lastSelectionIndex;
  if (index % [self numberOfItemsPerRow] != [self numberOfItemsPerRow]-1) {
    [self deselectAllItems];
    NSUInteger newIndex = index+1;
    [self selectItemAtIndex:newIndex];
    [self scrollRectToVisible:[self rectOfItemAtIndex:newIndex]];
  }
}

- (void)moveRightAndModifySelection:(id)sender
{
  if (lastSelectionIndex % [self numberOfItemsPerRow] != [self numberOfItemsPerRow]-1) {
    NSUInteger index = lastSelectionIndex+1;
    if ([selectionIndexes containsIndex:index])
      [self deselectItemAtIndex:lastSelectionIndex];
    else
      [self selectItemAtIndex:index];
    lastSelectionIndex = index;
    [self scrollRectToVisible:[self rectOfItemAtIndex:index]];
  }
}

- (void)moveUp:(id)sender
{
  NSUInteger index = lastSelectionIndex;
  if (index > [self numberOfItemsPerRow]-1) {
    [self deselectAllItems];
    NSUInteger newIndex = index-[self numberOfItemsPerRow];
    [self selectItemAtIndex:newIndex];
    [self scrollRectToVisible:[self rectOfItemAtIndex:newIndex]];
  }
}

- (void)moveUpAndModifySelection:(id)sender
{
  if (lastSelectionIndex > [self numberOfItemsPerRow]-1) {
    NSUInteger index = lastSelectionIndex - [self numberOfItemsPerRow];
    NSRange range    = NSMakeRange(index, [self numberOfItemsPerRow]);
    if ([selectionIndexes containsIndex:index]) {
      range.location++;
      [self deselectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    } else
      [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    lastSelectionIndex = index;
    [self scrollRectToVisible:[self rectOfItemAtIndex:index]];
  }
}

- (void)moveDown:(id)sender
{
  NSUInteger index = lastSelectionIndex;
  if (index + [self numberOfItemsPerRow] < [contentArray count]) {
    [self deselectAllItems];
    NSUInteger newIndex = index + [self numberOfItemsPerRow];
    [self selectItemAtIndex:newIndex];
    [self scrollRectToVisible:[self rectOfItemAtIndex:newIndex]];
  }
}

- (void)moveDownAndModifySelection:(id)sender
{
  NSUInteger index = lastSelectionIndex;
  if (index + [self numberOfItemsPerRow] < [contentArray count]) {
    NSUInteger index = lastSelectionIndex + [self numberOfItemsPerRow];
    NSRange range    = NSMakeRange(lastSelectionIndex, [self numberOfItemsPerRow]);
    if ([selectionIndexes containsIndex:index])
      [self deselectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    else {
      range.length++;
      [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
    lastSelectionIndex = index;
    [self scrollRectToVisible:[self rectOfItemAtIndex:index]];
  }
}

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
