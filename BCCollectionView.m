//  Created by Pieter Omvlee on 24/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView.h"
#import "BCGeometryExtensions.h"
#import "BCCollectionViewLayoutManager.h"
#import "BCCollectionViewLayoutItem.h"
#import "BCCollectionViewGroup.h"

@implementation BCCollectionView
@synthesize delegate, contentArray, groups, backgroundColor, originalSelectionIndexes, zoomValueObserverKey, accumulatedKeyStrokes, numberOfPreRenderedRows, layoutManager;
@dynamic visibleViewControllerArray;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    reusableViewControllers     = [[NSMutableArray alloc] init];
    visibleViewControllers      = [[NSMutableDictionary alloc] init];
    contentArray                = [[NSArray alloc] init];
    selectionIndexes            = [[NSMutableIndexSet alloc] init];
    dragHoverIndex              = NSNotFound;
    accumulatedKeyStrokes       = [[NSString alloc] init];
    numberOfPreRenderedRows     = 3;
    layoutManager               = [[BCCollectionViewLayoutManager alloc] initWithCollectionView:self];
    visibleGroupViewControllers = [[NSMutableDictionary alloc] init];
    
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
  } else if ([keyPath isEqualToString:@"isCollapsed"]) {
    [self performSelector:@selector(viewDidResize)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
      [self performSelector:@selector(scrollViewDidScroll:)];
    });
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
  
  for (BCCollectionViewGroup *group in groups)
    [group removeObserver:self forKeyPath:@"isCollapsed"];
  
  [layoutManager release];
  [reusableViewControllers release];
  [visibleViewControllers release];
  [visibleGroupViewControllers release];
  [contentArray release];
  [groups release];
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

- (NSUInteger)groupHeaderHeight
{
  return [delegate groupHeaderHeightForCollectionView:self];
}

- (NSIndexSet *)indexesOfItemsInRect:(NSRect)aRect
{
  NSArray *itemLayouts = [layoutManager itemLayouts];
  NSIndexSet *visibleIndexes = [itemLayouts indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id itemLayout, NSUInteger idx, BOOL *stop) {
    return NSIntersectsRect([itemLayout itemRect], aRect);
  }];
  return visibleIndexes;
}

- (NSIndexSet *)indexesOfItemContentRectsInRect:(NSRect)aRect
{
  NSArray *itemLayouts = [layoutManager itemLayouts];
  NSIndexSet *visibleIndexes = [itemLayouts indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id itemLayout, NSUInteger idx, BOOL *stop) {
    return NSIntersectsRect([itemLayout itemRect], aRect);
  }];
  return visibleIndexes;
  
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
  NSIndexSet *visibleIndexes = [self indexesOfItemsInRect:[self visibleRect]];
  return NSMakeRange([visibleIndexes firstIndex], [visibleIndexes lastIndex]-[visibleIndexes firstIndex]);
}

- (NSRange)rangeOfVisibleItemsWithOverflow
{
  NSRange range = [self rangeOfVisibleItems];
  NSInteger extraItems = [layoutManager maximumNumberOfItemsPerRow] * numberOfPreRenderedRows;
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

- (void)removeViewControllerForItemAtIndex:(NSUInteger)anIndex
{
  NSNumber *key = [NSNumber numberWithInteger:anIndex];
  NSViewController *viewController = [visibleViewControllers objectForKey:key];
  [[viewController view] removeFromSuperview];
  
  [self delegateUpdateDeselectionForItemAtIndex:anIndex];
  [self delegateViewControllerBecameInvisibleAtIndex:anIndex];
  
  [reusableViewControllers addObject:viewController];
  [visibleViewControllers removeObjectForKey:key];
}


- (void)removeInvisibleViewControllers
{
  [[self indexesOfInvisibleViewControllers] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [self removeViewControllerForItemAtIndex:idx];
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

- (void)addMissingViewControllerForItemAtIndex:(NSUInteger)anIndex withFrame:(NSRect)aRect
{
  NSViewController *viewController = [self emptyViewControllerForInsertion];
  [visibleViewControllers setObject:viewController forKey:[NSNumber numberWithInteger:anIndex]];
  [[viewController view] setFrame:aRect];
  [[viewController view] setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
  
  id itemToLoad = [contentArray objectAtIndex:anIndex];
  [delegate collectionView:self willShowViewController:viewController forItem:itemToLoad];
  [self addSubview:[viewController view]];
  if ([selectionIndexes containsIndex:anIndex])
    [self delegateUpdateSelectionForItemAtIndex:anIndex];
}

- (void)addMissingGroupHeaders
{
  if ([groups count] > 0) {
    [groups enumerateObjectsUsingBlock:^(id group, NSUInteger idx, BOOL *stop) {
      NSRect groupRect = NSMakeRect(0, NSMinY([layoutManager rectOfItemAtIndex:[group itemRange].location])-[self groupHeaderHeight],
                                    NSWidth([self visibleRect]), [self groupHeaderHeight]);
      BOOL groupShouldBeVisible = NSIntersectsRect(groupRect, [self visibleRect]);
      NSViewController *groupViewController = [visibleGroupViewControllers objectForKey:[NSNumber numberWithInteger:idx]];
      [[groupViewController view] setFrame:groupRect];
      if (groupShouldBeVisible && !groupViewController) {
        groupViewController = [delegate collectionView:self headerViewControllerForGroup:group];
        [self addSubview:[groupViewController view]];
        [visibleGroupViewControllers setObject:groupViewController forKey:[NSNumber numberWithInteger:idx]];
      } else if (!groupShouldBeVisible && groupViewController) {
        [[groupViewController view] removeFromSuperview];
        [visibleGroupViewControllers removeObjectForKey:[NSNumber numberWithInteger:idx]];
      }
    }];
  }
}

- (void)addMissingViewControllersToView
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSIndexSet indexSetWithIndexesInRange:[self rangeOfVisibleItemsWithOverflow]] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      if (![visibleViewControllers objectForKey:[NSNumber numberWithInteger:idx]]) {
        [self addMissingViewControllerForItemAtIndex:idx withFrame:[layoutManager rectOfItemAtIndex:idx]];
      }
    }];
    
    [self addMissingGroupHeaders];
  });
}

- (void)moveViewControllersToProperPosition
{
  for (NSNumber *number in visibleViewControllers) {
    NSRect r = [layoutManager rectOfItemAtIndex:[number integerValue]];
    if (!NSEqualRects(r, NSZeroRect))
      [[[visibleViewControllers objectForKey:number] view] setFrame:r];
  }
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
  if (index < [contentArray count]) {
    [selectionIndexes removeIndex:index];
    if ([self shoulDrawSelections])
      [self setNeedsDisplayInRect:[layoutManager rectOfItemAtIndex:index]];
    
    [self delegateDidDeselectItemAtIndex:index];
    [self delegateUpdateDeselectionForItemAtIndex:index];
  }
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
  frame.size.height = [self visibleRect].size.height;
  if ([contentArray count] > 0)
    frame.size.height = MAX(frame.size.height, NSMaxY([layoutManager rectOfItemAtIndex:[contentArray count]-1]));
  [self setFrame:frame];
}

- (void)reloadDataWithItems:(NSArray *)newContent emptyCaches:(BOOL)shouldEmptyCaches
{
  [self reloadDataWithItems:newContent groups:nil emptyCaches:shouldEmptyCaches];
}

- (void)reloadDataWithItems:(NSArray *)newContent groups:(NSArray *)newGroups emptyCaches:(BOOL)shouldEmptyCaches
{
  [self deselectAllItems];
  
  if (!delegate)
    return;
  
  for (BCCollectionViewGroup *group in groups)
    [group removeObserver:self forKeyPath:@"isCollapsed"];
  for (BCCollectionViewGroup *group in newGroups)
    [group addObserver:self forKeyPath:@"isCollapsed" options:0 context:NULL];
  
  self.groups       = newGroups;
  self.contentArray = newContent;
  
  [layoutManager enumerateItems:NULL completionBlock:^{
    [self resizeFrameToFitContents];
    
    if (shouldEmptyCaches) {
      for (NSViewController *viewController in [visibleViewControllers allValues]) {
        [[viewController view] removeFromSuperview];
        if ([delegate respondsToSelector:@selector(collectionView:viewControllerBecameInvisible:)])
          [delegate collectionView:self viewControllerBecameInvisible:viewController];
      }
      
      for (NSViewController *viewController in [visibleGroupViewControllers allValues])
        [[viewController view] removeFromSuperview];
      
      [reusableViewControllers removeAllObjects];
      [visibleViewControllers removeAllObjects];
      [visibleGroupViewControllers removeAllObjects];
    } else
      [self softReloadVisibleViewControllers];
    
    [selectionIndexes removeAllIndexes];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self addMissingViewControllersToView];
    });
  }];
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
  NSRect visibleRect = [self visibleRect];
  [layoutManager enumerateItems:^(BCCollectionViewLayoutItem *layoutItem) {
    BOOL shouldBeVisible = NSIntersectsRect([layoutItem itemRect], visibleRect);
    if (shouldBeVisible) {
      NSViewController *controller = [self viewControllerForItemAtIndex:[layoutItem itemIndex]];
//      if (controller  && ![[controller view] superview])
//        NSLog(@"nooooo");
      if (controller)
        [[controller view] setFrame:[layoutItem itemRect]];
      else
        [self addMissingViewControllerForItemAtIndex:[layoutItem itemIndex] withFrame:[layoutItem itemRect]];
    } else {
      if ([self viewControllerForItemAtIndex:[layoutItem itemIndex]])
        [self removeViewControllerForItemAtIndex:[layoutItem itemIndex]];
    }
  } completionBlock:^(void) {
    [self resizeFrameToFitContents];
    [self addMissingGroupHeaders];
  }];
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
