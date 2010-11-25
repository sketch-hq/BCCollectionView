//
//  BCCollectionView+Mouse.m
//  Fontcase
//
//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import "BCCollectionView+Mouse.h"
#import "BCGeometryExtensions.h"

@implementation BCCollectionView (BCCollectionView_Mouse)

- (BOOL)shiftOrCommandKeyPressed
{
  return [NSEvent modifierFlags] & NSShiftKeyMask || [NSEvent modifierFlags] & NSCommandKeyMask;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  [[self window] makeFirstResponder:self];
  
  if (![self shiftOrCommandKeyPressed])
    [self deselectAllItems];
  
  self.originalSelectionIndexes = [[selectionIndexes copy] autorelease];
  
  mouseDownLocation    = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  mouseDraggedLocation = mouseDownLocation;
  
  NSUInteger index = [self indexOfItemAtPoint:mouseDownLocation];
  if ([self shiftOrCommandKeyPressed] && [self.originalSelectionIndexes containsIndex:index])
    [self deselectItemAtIndex:index];
  else
    [self selectItemAtIndex:index];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  [self deselectAllItems];
  if ([self shiftOrCommandKeyPressed]) {
    [self.originalSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      [self selectItemAtIndex:idx];
    }];
  }
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  
  mouseDraggedLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  
  NSIndexSet *newIndexes = [self indexesOfItemsInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  [newIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    if ([self.originalSelectionIndexes containsIndex:idx])
      [self deselectItemAtIndex:idx];
    else
      [self selectItemAtIndex:idx];
  }];
  
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  [self setNeedsDisplayInRect:BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation)];
  
  mouseDownLocation    = NSZeroPoint;
  mouseDraggedLocation = NSZeroPoint;
  
  self.originalSelectionIndexes = nil;
}

@end
