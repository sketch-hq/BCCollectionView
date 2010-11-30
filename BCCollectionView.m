//
//  BCCollectionView.m
//  Fontcase
//
//  Created by Pieter Omvlee on 24/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import "BCCollectionView.h"
#import "BCGeometryExtensions.h"

@implementation BCCollectionView
@synthesize delegate, contentArray, backgroundColor, originalSelectionIndexes;

#pragma mark Setup and Teardown

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    reusableViewControllers = [[NSMutableArray alloc] init];
    visibleViewControllers  = [[NSMutableDictionary alloc] init];
    contentArray            = [[NSArray alloc] init];
    selectionIndexes        = [[NSMutableIndexSet alloc] init];
    
    [self addObserver:self forKeyPath:@"contentArray" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
    
    NSClipView *enclosingClipView = [[self enclosingScrollView] contentView];
    [enclosingClipView setPostsBoundsChangedNotifications:YES];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(scrollViewDidScroll:)
                   name:NSViewBoundsDidChangeNotification object:enclosingClipView];
    
    [center addObserver:self selector:@selector(viewDidResize) name:NSViewFrameDidChangeNotification  object:nil];
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:@"contentArray"])
    [self reloadData];
  else if ([keyPath isEqualToString:@"backgroundColor"])
    [self setNeedsDisplay:YES];
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
  [self removeObserver:self forKeyPath:@"contentArray"];
  [self removeObserver:self forKeyPath:@"backgroundColor"];
  
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self name:NSViewBoundsDidChangeNotification object:[[self enclosingScrollView] contentView]];
  [center removeObserver:self name:NSViewFrameDidChangeNotification object:nil];
  
  [reusableViewControllers release];
  [visibleViewControllers release];
  [contentArray release];
  [selectionIndexes release];
  [originalSelectionIndexes release];
  [super dealloc];
}

#pragma mark Drawing Selections

- (BOOL)shoulDrawSelections
{
  if ([delegate respondsToSelector:@selector(collectionViewShouldDrawSelections:)])
    return [delegate collectionViewShouldDrawSelections:self];
  else
    return YES;
}

//- (void)drawSelectionForItemAtIndex:(NSUInteger)index

- (void)drawItemSelectionInRect:(NSRect)aRect
{
  NSRect insetRect = NSInsetRect(aRect, 10, 10);
  if ([self needsToDrawRect:insetRect]) {  
    [[NSColor lightGrayColor] set];
    [[NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:10 yRadius:10] fill];
  }
}

- (void)drawRect:(NSRect)dirtyRect
{
  [backgroundColor ? backgroundColor : [NSColor whiteColor] set];
  NSRectFill(dirtyRect);
  
  [[NSColor grayColor] set];
  NSFrameRect(BCRectFromTwoPoints(mouseDownLocation, mouseDraggedLocation));
  
  if ([selectionIndexes count] > 0 && [self shoulDrawSelections]) {
    for (NSNumber *number in visibleViewControllers) {
      if ([selectionIndexes containsIndex:[number integerValue]])
        [self drawItemSelectionInRect:[[[visibleViewControllers objectForKey:number] view] frame]];
    }
  }
}

- (BOOL)isFlipped
{
  return YES;
}

#pragma mark Delegate Call Wrappers

- (NSViewController *)viewControllerForItemAtIndex:(NSUInteger)index
{
  return [visibleViewControllers objectForKey:[NSNumber numberWithInteger:index]];
}

- (void)delegateUpdateSelectionForItemAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:updateViewControllerAsSelected:forItem:)])
    [delegate collectionView:self updateViewControllerAsSelected:[self viewControllerForItemAtIndex:index]
               forItem:[contentArray objectAtIndex:index]];
}

- (void)delegateUpdateDeselectionForItemAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:updateViewControllerAsDeselected:forItem:)])
    [delegate collectionView:self updateViewControllerAsDeselected:[self viewControllerForItemAtIndex:index]
               forItem:[contentArray objectAtIndex:index]];
}

- (void)delegateDidSelectItemAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:didSelectItem:withViewController:)])
    [delegate collectionView:self
         didSelectItem:[contentArray objectAtIndex:index]
    withViewController:[self viewControllerForItemAtIndex:index]];
}

- (void)delegateDidDeselectItemAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:didDeselectItem:withViewController:)])
    [delegate collectionView:self
       didDeselectItem:[contentArray objectAtIndex:index]
    withViewController:[self viewControllerForItemAtIndex:index]];
}

- (void)delegateViewControllerBecameInvisibleAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:viewControllerBecameInvisible:)])
    [delegate collectionView:self viewControllerBecameInvisible:[self viewControllerForItemAtIndex:index]];
}

#pragma mark Basic Information

- (NSUInteger)numberOfRows
{
  return ceil([contentArray count]/[self numberOfItemsPerRow]);
}

- (NSUInteger)numberOfItemsPerRow
{
  return [self frame].size.width/[self cellSize].width;
}

- (NSSize)cellSize
{
  return [delegate cellSizeForCollectionView:self];
}

- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p
{
  NSUInteger index = (int)(p.y / [self cellSize].height) * [self numberOfItemsPerRow] + p.x / [self cellSize].width;
  if (index >= [contentArray count])
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

- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex
{
  NSSize cellSize = [self cellSize];
  NSUInteger rowIndex    = anIndex / [self numberOfItemsPerRow];
  NSUInteger columnIndex = anIndex % [self numberOfItemsPerRow];
  
  return NSMakeRect(columnIndex*cellSize.width, rowIndex*cellSize.height, cellSize.width, cellSize.height);
}

- (NSIndexSet *)indexesOfItemsInRect:(NSRect)aRect
{
  NSUInteger firstIndex = [self indexOfItemAtPoint:NSMakePoint(NSMinX(aRect), NSMinY(aRect))];
  NSUInteger lastIndex  = [self indexOfItemAtPoint:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
  
  if (firstIndex == NSNotFound)
    firstIndex = 0;
  
  if (lastIndex == NSNotFound)
    lastIndex = [contentArray count]-1;
  
  NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
  for (NSUInteger i=firstIndex; i<lastIndex+1; i++) {
    if (NSIntersectsRect(aRect, [self rectOfItemAtIndex:i]))
      [indexes addIndex:i];
  }
  return indexes;
}

- (NSRange)rangeOfVisibleItems
{
  NSRect visibleRect = [self visibleRect];
  NSUInteger firstIndex = [self indexOfItemAtPointOrClosestGuess:NSMakePoint(NSMinX(visibleRect), NSMinY(visibleRect))];
  NSUInteger lastIndex  = [self indexOfItemAtPointOrClosestGuess:NSMakePoint(NSMaxX(visibleRect), NSMaxY(visibleRect))];
  return NSIntersectionRange(NSMakeRange(firstIndex, lastIndex-firstIndex),
                             NSMakeRange(0, [contentArray count]));

}

#pragma mark Querying ViewControllers

- (NSIndexSet *)indexesOfViewControllers
{
  NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
  for (NSNumber *number in [visibleViewControllers allKeys])
    [set addIndex:[number integerValue]];
  return set;
}

- (NSIndexSet *)indexesOfInvisibleViewControllers
{
  NSRange visibleRange = [self rangeOfVisibleItems];
  return [[self indexesOfViewControllers] indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
    return !NSLocationInRange(idx, visibleRange);
  }];
}

- (void)removeInvisibleViewControllers
{
  [[self indexesOfInvisibleViewControllers] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSNumber *key = [NSNumber numberWithInteger:idx];
    NSViewController *viewController = [visibleViewControllers objectForKey:key];
    dispatch_async(dispatch_get_main_queue(), ^{
      [[viewController view] removeFromSuperview];
    });
    
    [self delegateUpdateDeselectionForItemAtIndex:idx];
    [self delegateViewControllerBecameInvisibleAtIndex:idx];
        
    [reusableViewControllers addObject:viewController];
    [visibleViewControllers removeObjectForKey:key];
  }];
}

- (NSViewController *)usableViewController
{
  if ([reusableViewControllers count] > 0) {
    NSViewController *viewController = [[[reusableViewControllers lastObject] retain] autorelease];
    [reusableViewControllers removeLastObject];
    return viewController;
  } else
    return [delegate reusableViewControllerForCollectionView:self];
}

- (void)addMissingViewControllers
{
  [[NSIndexSet indexSetWithIndexesInRange:[self rangeOfVisibleItems]]
   enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSNumber *key = [NSNumber numberWithInteger:idx];
    if (![visibleViewControllers objectForKey:key]) {
      NSViewController *viewController = [self usableViewController];
      [visibleViewControllers setObject:viewController forKey:key];
      [[viewController view] setFrame:[self rectOfItemAtIndex:idx]];
      [[viewController view] setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
      
      id itemToLoad = [contentArray objectAtIndex:idx];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [delegate collectionView:self willShowViewController:viewController forItem:itemToLoad];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self addSubview:[viewController view]];
          if ([selectionIndexes containsIndex:idx])
            [self delegateUpdateSelectionForItemAtIndex:idx];
        });
      });
    }
  }];
}

- (void)removeAllViewControllers
{
  for (NSViewController *viewController in [visibleViewControllers allValues])
    [[viewController view] removeFromSuperview];
  
  [reusableViewControllers removeAllObjects];
  [visibleViewControllers removeAllObjects];
}

- (void)moveViewControllersToProperPosition
{
  for (NSNumber *number in visibleViewControllers)
    [[[visibleViewControllers objectForKey:number] view] setFrame:[self rectOfItemAtIndex:[number integerValue]]];
}

#pragma mark Selecting and Deselecting Items

- (void)selectItemAtIndex:(NSUInteger)index
{
  [self selectItemAtIndex:index inBulk:NO];
}

- (void)selectItemAtIndex:(NSUInteger)index inBulk:(BOOL)bulkSelecting
{
  if (index >= [contentArray count])
    return;
    
  BOOL maySelectItem = YES;
  NSViewController *viewController = [self viewControllerForItemAtIndex:index];
  id item = [contentArray objectAtIndex:index];
  
  if ([delegate respondsToSelector:@selector(collectionView:shouldSelectItem:withViewController:)])
    maySelectItem = [delegate collectionView:self shouldSelectItem:item withViewController:viewController];
  
  if (maySelectItem) {
    [selectionIndexes addIndex:index];
    [self delegateUpdateSelectionForItemAtIndex:index];
    [self delegateDidSelectItemAtIndex:index];
    if ([self shoulDrawSelections])
      [self setNeedsDisplayInRect:[self rectOfItemAtIndex:index]];
  }
  
  if (!bulkSelecting)
    lastSelectionIndex = index;
}

- (void)selectItemsAtIndexes:(NSIndexSet *)indexes
{
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [self selectItemAtIndex:idx inBulk:YES];
  }];
  lastSelectionIndex = [indexes firstIndex];
}

- (void)deselectItemAtIndex:(NSUInteger)index
{
  [selectionIndexes removeIndex:index];
  if ([self shoulDrawSelections])
    [self setNeedsDisplayInRect:[self rectOfItemAtIndex:index]];
  
  [self delegateDidDeselectItemAtIndex:index];
  [self delegateUpdateDeselectionForItemAtIndex:index];
}

- (void)deselectItemsAtIndexes:(NSIndexSet *)indexes
{
  [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [self deselectItemAtIndex:idx];
  }];
}

- (void)deselectAllItems
{
  [selectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [self deselectItemAtIndex:idx];
  }];
}

- (void)selectAll:(id)sender
{
  [self selectItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[contentArray count])]];
}

#pragma mark User-interaction

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (BOOL)canBecomeKeyView
{
  return YES;
}

#pragma mark Reloading and Updating the Icon View

- (void)reloadData
{
  if (!delegate)
    return;
  
  NSRect frame = [self frame];
  frame.size.height = [self visibleRect].size.height;
  frame.size.height = MAX(frame.size.height, [self numberOfRows] * [self cellSize].height);
  [self setFrame:frame];
  
  [self removeAllViewControllers];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self addMissingViewControllers];
  });
}

- (void)scrollViewDidScroll:(NSScrollView *)scrollView
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self removeInvisibleViewControllers];
    [self addMissingViewControllers];
  });
  
  if ([delegate respondsToSelector:@selector(collectionViewDidScroll:)])
    [delegate collectionViewDidScroll:self];
}

- (void)viewDidResize
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self moveViewControllersToProperPosition];
    [self addMissingViewControllers];
  });
}

@end
