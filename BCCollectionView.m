//  Created by Pieter Omvlee on 24/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView.h"
#import "BCGeometryExtensions.h"
#import "BCCollectionViewLayoutManager.h"

@implementation BCCollectionView
@synthesize delegate, contentArray, backgroundColor, originalSelectionIndexes, zoomValueObserverKey, accumulatedKeyStrokes, numberOfPreRenderedRows;
@dynamic visibleViewControllerArray;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    reusableViewControllers = [[NSMutableArray alloc] init];
    visibleViewControllers  = [[NSMutableDictionary alloc] init];
    contentArray            = [[NSArray alloc] init];
    selectionIndexes        = [[NSMutableIndexSet alloc] init];
    dragHoverIndex          = NSNotFound;
    accumulatedKeyStrokes   = [[NSString alloc] init];
    numberOfPreRenderedRows = 3;
    layoutManager           = [[BCCollectionViewLayoutManager alloc] initWithCollectionView:self];
    
    [self addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
    
    NSClipView *enclosingClipView = [[self enclosingScrollView] contentView];
    [enclosingClipView setPostsBoundsChangedNotifications:YES];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(scrollViewDidScroll:) name:NSViewBoundsDidChangeNotification object:enclosingClipView];
    [center addObserver:self selector:@selector(viewDidResize) name:NSViewFrameDidChangeNotification object:self];
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"backgroundColor"])
    [self setNeedsDisplay:YES];
  else if ([keyPath isEqual:zoomValueObserverKey]) {
    if ([self respondsToSelector:@selector(zoomValueDidChange)])
      [self performSelector:@selector(zoomValueDidChange)];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)dealloc
{
  [self removeObserver:self forKeyPath:@"backgroundColor"];
  [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:zoomValueObserverKey];

  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self name:NSViewBoundsDidChangeNotification object:[[self enclosingScrollView] contentView]];
  [center removeObserver:self name:NSViewFrameDidChangeNotification object:self];
  
  [layoutManager release];
  [reusableViewControllers release];
  [visibleViewControllers release];
  [contentArray release];
  [selectionIndexes release];
  [originalSelectionIndexes release];
  [accumulatedKeyStrokes release];
  [zoomValueObserverKey release];
  [super dealloc];
}

- (BOOL)isFlipped
{
  return YES;
}

#pragma mark Drawing Selections

- (BOOL)shoulDrawSelections
{
  if ([delegate respondsToSelector:@selector(collectionViewShouldDrawSelections:)])
    return [delegate collectionViewShouldDrawSelections:self];
  else
    return YES;
}

- (BOOL)shoulDrawHover
{
  if ([delegate respondsToSelector:@selector(collectionViewShouldDrawHover:)])
    return [delegate collectionViewShouldDrawHover:self];
  else
    return YES;
}

- (void)drawItemSelectionForInRect:(NSRect)aRect
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
    for (NSNumber *number in visibleViewControllers)
      if ([selectionIndexes containsIndex:[number integerValue]])
        [self drawItemSelectionForInRect:[[[visibleViewControllers objectForKey:number] view] frame]];
  }
  
  if (dragHoverIndex != NSNotFound && [self shoulDrawHover])
    [self drawItemSelectionForInRect:[[[visibleViewControllers objectForKey:[NSNumber numberWithInteger:dragHoverIndex]] view] frame]];
}

#pragma mark Delegate Call Wrappers

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

- (void)delegateCollectionViewSelectionDidChange
{
  if ([delegate respondsToSelector:@selector(collectionViewSelectionDidChange:)]) {
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(collectionViewSelectionDidChange:) target:delegate argument:self];
    [(id)delegate performSelector:@selector(collectionViewSelectionDidChange:) withObject:self afterDelay:0.0];
  }
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
  
  [self delegateCollectionViewSelectionDidChange];
}

- (void)delegateViewControllerBecameInvisibleAtIndex:(NSUInteger)index
{
  if ([delegate respondsToSelector:@selector(collectionView:viewControllerBecameInvisible:)])
    [delegate collectionView:self viewControllerBecameInvisible:[self viewControllerForItemAtIndex:index]];
}

- (NSSize)cellSize
{
  return [delegate cellSizeForCollectionView:self];
}

- (NSIndexSet *)indexesOfItemsInRect:(NSRect)aRect
{
  NSUInteger firstIndex = [layoutManager indexOfItemAtPoint:NSMakePoint(NSMinX(aRect), NSMinY(aRect))];
  NSUInteger lastIndex  = [layoutManager indexOfItemAtPoint:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
  
  if (firstIndex == NSNotFound)
    firstIndex = 0;
  
  if (lastIndex == NSNotFound)
    lastIndex = [contentArray count]-1;
  
  NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
  for (NSUInteger i=firstIndex; i<lastIndex+1; i++) {
    if (NSIntersectsRect(aRect, [layoutManager rectOfItemAtIndex:i]))
      [indexes addIndex:i];
  }
  return indexes;
}

- (NSIndexSet *)indexesOfItemContentRectsInRect:(NSRect)aRect
{
  NSUInteger firstIndex = [layoutManager indexOfItemContentRectAtPoint:NSMakePoint(NSMinX(aRect), NSMinY(aRect))];
  NSUInteger lastIndex  = [layoutManager indexOfItemContentRectAtPoint:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect))];
  
  if (firstIndex == NSNotFound)
    firstIndex = 0;
  
  if (lastIndex == NSNotFound)
    lastIndex = [contentArray count]-1;
  
  NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
  for (NSUInteger i=firstIndex; i<lastIndex+1; i++) {
    if (NSIntersectsRect(aRect, [layoutManager contentRectOfItemAtIndex:i]))
      [indexes addIndex:i];
  }
  return indexes;
}

- (NSRange)rangeOfVisibleItems
{
  NSRect visibleRect = [self visibleRect];
  NSUInteger firstIndex = [layoutManager indexOfItemAtPointOrClosestGuess:NSMakePoint(NSMinX(visibleRect), NSMinY(visibleRect))];
  NSUInteger lastIndex  = [layoutManager indexOfItemAtPointOrClosestGuess:NSMakePoint(NSMaxX(visibleRect), NSMaxY(visibleRect))];
  return NSIntersectionRange(NSMakeRange(firstIndex, lastIndex-firstIndex),
                             NSMakeRange(0, [contentArray count]));
}

- (NSRange)rangeOfVisibleItemsWithOverflow
{
  NSRange range = [self rangeOfVisibleItems];
  NSInteger extraItems = [layoutManager numberOfItemsAtRow:0] * numberOfPreRenderedRows;
  NSInteger min = range.location;
  NSInteger max = range.location + range.length;
  
  min = MAX(0, min-extraItems);
  max = MIN([contentArray count], max+extraItems);
  return NSMakeRange(min, max-min);
}

#pragma mark Querying ViewControllers

- (NSIndexSet *)indexesOfViewControllers
{
  NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
  for (NSNumber *number in [visibleViewControllers allKeys])
    [set addIndex:[number integerValue]];
  return set;
}

- (NSArray *)visibleViewControllerArray
{
  return [visibleViewControllers allValues];
}

- (NSIndexSet *)indexesOfInvisibleViewControllers
{
  NSRange visibleRange = [self rangeOfVisibleItemsWithOverflow];
  return [[self indexesOfViewControllers] indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
    return !NSLocationInRange(idx, visibleRange);
  }];
}

- (NSViewController *)viewControllerForItemAtIndex:(NSUInteger)index
{
  return [visibleViewControllers objectForKey:[NSNumber numberWithInteger:index]];
}

#pragma mark Swapping ViewControllers in and out

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

- (NSViewController *)emptyViewControllerForInsertion
{
  if ([reusableViewControllers count] > 0) {
    NSViewController *viewController = [[[reusableViewControllers lastObject] retain] autorelease];
    [reusableViewControllers removeLastObject];
    return viewController;
  } else
    return [delegate reusableViewControllerForCollectionView:self];
}

- (void)addMissingViewControllersToView
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSIndexSet indexSetWithIndexesInRange:[self rangeOfVisibleItemsWithOverflow]] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      NSNumber *key = [NSNumber numberWithInteger:idx];
      if (![visibleViewControllers objectForKey:key]) {
        NSViewController *viewController = [self emptyViewControllerForInsertion];
        [visibleViewControllers setObject:viewController forKey:key];
        [[viewController view] setFrame:[layoutManager rectOfItemAtIndex:idx]];
        [[viewController view] setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
        
        id itemToLoad = [contentArray objectAtIndex:idx];
        [delegate collectionView:self willShowViewController:viewController forItem:itemToLoad];
        [self addSubview:[viewController view]];
        if ([selectionIndexes containsIndex:idx])
          [self delegateUpdateSelectionForItemAtIndex:idx];
      }
    }];
  });
}

- (void)moveViewControllersToProperPosition
{
  for (NSNumber *number in visibleViewControllers)
    [[[visibleViewControllers objectForKey:number] view] setFrame:[layoutManager rectOfItemAtIndex:[number integerValue]]];
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
    if (!bulkSelecting)
      [self delegateCollectionViewSelectionDidChange];
    if ([self shoulDrawSelections])
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:index]];
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
  [self delegateCollectionViewSelectionDidChange];
}

- (void)deselectItemAtIndex:(NSUInteger)index
{
  [selectionIndexes removeIndex:index];
  if ([self shoulDrawSelections])
    [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:index]];
  
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

- (NSIndexSet *)selectionIndexes
{
  return selectionIndexes;
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

- (void)softReloadVisibleViewControllers
{
  NSMutableArray *removeKeys = [NSMutableArray array];
  
  for (NSString *number in visibleViewControllers) {
    NSUInteger index             = [number integerValue];
    NSViewController *controller = [visibleViewControllers objectForKey:number];
    
    if (index < [contentArray count]) {
      if ([selectionIndexes containsIndex:index])
        [self delegateUpdateDeselectionForItemAtIndex:index];
      [delegate collectionView:self willShowViewController:controller forItem:[contentArray objectAtIndex:index]];
    } else {
      if ([selectionIndexes containsIndex:index])
        [self delegateUpdateDeselectionForItemAtIndex:index];
      
      [self delegateViewControllerBecameInvisibleAtIndex:index];
      [[controller view] removeFromSuperview];
      [reusableViewControllers addObject:controller];
      [removeKeys addObject:number];
    }
  }
  [visibleViewControllers removeObjectsForKeys:removeKeys];
}

- (void)resizeFrameToFitContents
{
  NSRect frame = [self frame];
  frame.size.height = MAX([self visibleRect].size.height, [layoutManager numberOfRows] * [self cellSize].height);
  [self setFrame:frame];
}

- (void)reloadDataWithItems:(NSArray *)newContent emptyCaches:(BOOL)shouldEmptyCaches
{
  [self deselectAllItems];
  
  if (!delegate)
    return;
  
  self.contentArray = newContent;
  [layoutManager willReload];
  [self resizeFrameToFitContents];
  
  if (shouldEmptyCaches) {
    for (NSViewController *viewController in [visibleViewControllers allValues]) {
      [[viewController view] removeFromSuperview];
      if ([delegate respondsToSelector:@selector(collectionView:viewControllerBecameInvisible:)])
        [delegate collectionView:self viewControllerBecameInvisible:viewController];
    }
    
    [reusableViewControllers removeAllObjects];
    [visibleViewControllers removeAllObjects];
  } else
    [self softReloadVisibleViewControllers];
  
  [selectionIndexes removeAllIndexes];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self addMissingViewControllersToView];
  });
}

- (void)scrollViewDidScroll:(NSNotification *)note
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self removeInvisibleViewControllers];
    [self addMissingViewControllersToView];
  });
  
  if ([delegate respondsToSelector:@selector(collectionViewDidScroll:inDirection:)]) {
    if ([self visibleRect].origin.y > previousFrameBounds.origin.y)
      [delegate collectionViewDidScroll:self inDirection:BCCollectionViewScrollDirectionDown];
    else
      [delegate collectionViewDidScroll:self inDirection:BCCollectionViewScrollDirectionUp];
    previousFrameBounds = [self visibleRect];
  }
}

- (void)viewDidResize
{
  [layoutManager willReload];
  [self resizeFrameToFitContents];
  dispatch_async(dispatch_get_main_queue(), ^{
    [layoutManager willReload];
    [self moveViewControllersToProperPosition];
    [self addMissingViewControllersToView];
  });
}

- (NSMenu *)menuForEvent:(NSEvent *)anEvent
{
  if ([delegate respondsToSelector:@selector(collectionView:menuForItemsAtIndexes:)])
    return [delegate collectionView:self menuForItemsAtIndexes:[self selectionIndexes]];
  else
    return nil;
}

- (BOOL)isOpaque
{
  return YES;
}

@end
