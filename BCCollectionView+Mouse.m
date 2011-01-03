//
//  BCCollectionView+Mouse.m
//  Fontcase
//
//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import "BCCollectionView+Mouse.h"
#import "BCGeometryExtensions.h"
#import "BCCollectionView+Dragging.h"

@implementation BCCollectionView (BCCollectionView_Mouse)

- (BOOL)shiftOrCommandKeyPressed
{
  return [NSEvent modifierFlags] & NSShiftKeyMask || [NSEvent modifierFlags] & NSCommandKeyMask;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  [[self window] makeFirstResponder:self];
  
  mouseDownLocation    = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  mouseDraggedLocation = mouseDownLocation;
  NSUInteger index     = [self indexOfItemContentRectAtPoint:mouseDownLocation];
  
  if (![self shiftOrCommandKeyPressed] && ![selectionIndexes containsIndex:index])
    [self deselectAllItems];
  
  self.originalSelectionIndexes = [[selectionIndexes copy] autorelease];
  
  if ([theEvent clickCount] == 2 && [delegate respondsToSelector:@selector(collectionView:didDoubleClickViewControllerAtIndex:)])
    [delegate collectionView:self didDoubleClickViewControllerAtIndex:[visibleViewControllers objectForKey:[NSNumber numberWithInt:[self indexOfItemAtPoint:mouseDownLocation]]]];
  
  if ([self shiftOrCommandKeyPressed] && [self.originalSelectionIndexes containsIndex:index])
    [self deselectItemAtIndex:index];
  else
    [self selectItemAtIndex:index];
  
  firstDrag = YES;
}

- (void)regularMouseDragged:(NSEvent *)anEvent
{
  [self deselectAllItems];
  if ([self shiftOrCommandKeyPressed]) {
    [self.originalSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      [self selectItemAtIndex:idx];
    }];
  }
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  
  mouseDraggedLocation = [self convertPoint:[anEvent locationInWindow] fromView:nil];
  
  NSIndexSet *newIndexes = [self indexesOfItemContentRectsInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  [newIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    if ([self.originalSelectionIndexes containsIndex:idx])
      [self deselectItemAtIndex:idx];
    else
      [self selectItemAtIndex:idx];
  }];
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  if (firstDrag && [selectionIndexes count] > 0 && [self delegateSupportsDragForItemsAtIndexes:selectionIndexes])
    [self initiateDraggingSessionWithEvent:theEvent];
  else
    [self regularMouseDragged:theEvent];
  firstDrag = NO;
}

- (void)mouseUp:(NSEvent *)theEvent
{
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  
  mouseDownLocation    = NSZeroPoint;
  mouseDraggedLocation = NSZeroPoint;
  
  self.originalSelectionIndexes = nil;
}

@end
