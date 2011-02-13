//  Created by Pieter Omvlee on 24/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "BCCollectionViewDelegate.h"

@interface BCCollectionView : NSView
{
  IBOutlet id<BCCollectionViewDelegate> delegate;
  
  NSArray *contentArray;
  
  NSMutableArray      *reusableViewControllers;
  NSMutableDictionary *visibleViewControllers;
  NSMutableIndexSet   *selectionIndexes;
  
  NSColor *backgroundColor;
  NSUInteger  numberOfPreRenderedRows;
  
@private
  NSPoint mouseDownLocation;
  NSPoint mouseDraggedLocation;
  NSRect previousFrameBounds;
  
  NSUInteger lastSelectionIndex;
  NSIndexSet *originalSelectionIndexes;
  NSInteger dragHoverIndex;
  
  BOOL isDragging;
  BOOL firstDrag;
  
  NSString *zoomValueObserverKey;
  CGFloat lastPinchMagnification;
  
  NSString *accumulatedKeyStrokes;
}
@property (nonatomic, assign) id<BCCollectionViewDelegate> delegate;
@property (nonatomic, retain) NSColor *backgroundColor;
@property (nonatomic) NSUInteger numberOfPreRenderedRows;

//private
@property (nonatomic, copy) NSIndexSet *originalSelectionIndexes;
@property (nonatomic, copy) NSArray *contentArray;
@property (nonatomic, copy) NSString *zoomValueObserverKey, *accumulatedKeyStrokes;

//designated way to load BCCollectionView
- (void)reloadDataWithItems:(NSArray *)newContent emptyCaches:(BOOL)shouldEmptyCaches;

//Managing Selections
- (void)selectItemAtIndex:(NSUInteger)index;
- (void)selectItemAtIndex:(NSUInteger)index inBulk:(BOOL)bulk;

- (void)selectItemsAtIndexes:(NSIndexSet *)indexes;
- (void)deselectItemAtIndex:(NSUInteger)index;
- (void)deselectItemsAtIndexes:(NSIndexSet *)indexes;
- (void)deselectAllItems;
- (NSIndexSet *)selectionIndexes;

//Basic Cell Information
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfItemsPerRow;
- (NSSize)cellSize;
- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p;
- (NSRange)rangeOfVisibleItems;
- (NSRange)rangeOfVisibleItemsWithOverflow;

- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex;
- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex;

- (NSUInteger)indexOfItemAtPoint:(NSPoint)p;
- (NSUInteger)indexOfItemContentRectAtPoint:(NSPoint)p;

- (NSIndexSet *)indexesOfItemsInRect:(NSRect)aRect;
- (NSIndexSet *)indexesOfItemContentRectsInRect:(NSRect)aRect;

//Querying ViewControllers
- (NSIndexSet *)indexesOfViewControllers;
- (NSIndexSet *)indexesOfInvisibleViewControllers;
- (NSViewController *)viewControllerForItemAtIndex:(NSUInteger)index;
@end
