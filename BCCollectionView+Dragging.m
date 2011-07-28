//  Created by Pieter Omvlee on 13/12/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView+Dragging.h"
#import "BCCollectionViewLayoutManager.h"

@implementation BCCollectionView (BCCollectionView_Dragging)

- (void)initiateDraggingSessionWithEvent:(NSEvent *)anEvent
{
  NSUInteger index = [layoutManager indexOfItemAtPoint:mouseDownLocation];
  [self selectItemAtIndex:index];
  
  NSRect itemRect     = [layoutManager rectOfItemAtIndex:index];
  NSView *currentView = [[self viewControllerForItemAtIndex:index] view];
  NSData *imageData   = [currentView dataWithPDFInsideRect:NSMakeRect(0,0,NSWidth(itemRect),NSHeight(itemRect))];
  NSImage *pdfImage   = [[[NSImage alloc] initWithData:imageData] autorelease];
  NSImage *dragImage  = [[NSImage alloc] initWithSize:[pdfImage size]];
  
  if ([dragImage size].width > 0 && [dragImage size].height > 0) {
    [dragImage lockFocus];
    [pdfImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.5];
    [dragImage unlockFocus];
  }
  
  NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [self delegateWriteIndexes:selectionIndexes toPasteboard:pasteboard];
  [self retain];
  [self dragImage:[dragImage autorelease]
               at:NSMakePoint(NSMinX(itemRect), NSMaxY(itemRect))
           offset:NSMakeSize(0, 0)
            event:anEvent
       pasteboard:pasteboard
           source:self
        slideBack:YES];
}

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
  [self retain];
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
  [self autorelease];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
  if ([delegate respondsToSelector:@selector(collectionView:draggingEntered:)])
    return [delegate collectionView:self draggingEntered:sender];
  else
    return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  NSPoint mouse    = [self convertPoint:[sender draggingLocation] fromView:nil];
  NSUInteger index = [layoutManager indexOfItemAtPoint:mouse];
  
  NSDragOperation operation = NSDragOperationNone;
  if ([sender draggingSource] == self) {
    if ([selectionIndexes containsIndex:index])
      [self setDragHoverIndex:NSNotFound];
    else if ([self delegateCanDrop:sender onIndex:index]) {
      [self setDragHoverIndex:index];
      operation = NSDragOperationMove;
    } else
      [self setDragHoverIndex:NSNotFound]; 
  } else {
    if ([self delegateCanDrop:sender onIndex:index]) {
      [self setDragHoverIndex:index];
      operation = NSDragOperationCopy;
    }
  }
  
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  return operation;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
  if (dragHoverIndex != NSNotFound)
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  
  [self setDragHoverIndex:NSNotFound];
  
  if ([delegate respondsToSelector:@selector(collectionView:draggingEnded:)])
    [delegate collectionView:self draggingEnded:sender];
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
  NSPoint mouse    = [self convertPoint:[sender draggingLocation] fromView:nil];
  NSUInteger index = [layoutManager indexOfItemAtPoint:mouse];
  
  if (index == NSNotFound) {
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
    [self setDragHoverIndex:NSNotFound];
    
    if ([delegate respondsToSelector:@selector(collectionView:draggingExited:)])
      [delegate collectionView:self draggingExited:sender];
  }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  id item = nil;
  if (dragHoverIndex >= 0 && dragHoverIndex <[contentArray count])
    item = [contentArray objectAtIndex:dragHoverIndex];
  
  if ([delegate respondsToSelector:@selector(collectionView:performDragOperation:onViewController:forItem:)])
    return [delegate collectionView:self performDragOperation:sender onViewController:[self viewControllerForItemAtIndex:dragHoverIndex] forItem:item];
  else
    return NO;
}

#pragma mark -
#pragma mark Delegate Shortcuts

- (void)setDragHoverIndex:(NSInteger)hoverIndex
{
  if (hoverIndex != dragHoverIndex) {
    if (dragHoverIndex != NSNotFound)
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
    
    if ([delegate respondsToSelector:@selector(collectionView:dragExitedViewController:)])
      [delegate collectionView:self dragExitedViewController:[self viewControllerForItemAtIndex:dragHoverIndex]];
    
    dragHoverIndex = hoverIndex;
    
    if ([delegate respondsToSelector:@selector(collectionView:dragEnteredViewController:)])
      [delegate collectionView:self dragEnteredViewController:[self viewControllerForItemAtIndex:dragHoverIndex]];
    
    if (dragHoverIndex != NSNotFound)
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:dragHoverIndex]];
  }
}

- (BOOL)delegateSupportsDragForItemsAtIndexes:(NSIndexSet *)indexSet
{
  if ([delegate respondsToSelector:@selector(collectionView:canDragItemsAtIndexes:)])
    return [delegate collectionView:self canDragItemsAtIndexes:indexSet];
  return NO;
}

- (void)delegateWriteIndexes:(NSIndexSet *)indexSet toPasteboard:(NSPasteboard *)pasteboard
{
  if ([delegate respondsToSelector:@selector(collectionView:writeItemsAtIndexes:toPasteboard:)])
    [delegate collectionView:self writeItemsAtIndexes:indexSet toPasteboard:pasteboard];
}

- (BOOL)delegateCanDrop:(id)draggingInfo onIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:validateDrop:onItemAtIndex:)])
    return [delegate collectionView:self validateDrop:draggingInfo onItemAtIndex:index];
  else
    return NO;
}

@end
