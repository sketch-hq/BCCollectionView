//
//  BCCollectionView.h
//  Fontcase
//
//  Created by Pieter Omvlee on 24/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BCCollectionViewDelegate.h"

@interface BCCollectionView : NSView
{
  IBOutlet id<BCCollectionViewDelegate> delegate;
  
  NSArray *contentArray;
  
  NSMutableArray      *reusableViewControllers;
  NSMutableDictionary *visibleViewControllers;
  
  NSMutableIndexSet   *selectionIndexes;
  NSIndexSet          *originalSelectionIndexes;
  
  NSColor *backgroundColor;
  
  NSUInteger lastSelectionIndex;
  
@private
  NSPoint mouseDownLocation;
  NSPoint mouseDraggedLocation;
  NSRect previousFrameBounds;
}
@property (nonatomic, assign) id<BCCollectionViewDelegate> delegate;
@property (nonatomic, retain) NSColor *backgroundColor;

//private
@property (nonatomic, copy) NSIndexSet *originalSelectionIndexes;
@property (nonatomic, copy) NSArray *contentArray;

- (void)reloadDataWithItems:(NSArray *)newContent emptyCaches:(BOOL)shouldEmptyCaches;

//Managing Selections
- (void)selectItemAtIndex:(NSUInteger)index;
- (void)selectItemAtIndex:(NSUInteger)index inBulk:(BOOL)bulk;

- (void)selectItemsAtIndexes:(NSIndexSet *)indexes;
- (void)deselectItemAtIndex:(NSUInteger)index;
- (void)deselectItemsAtIndexes:(NSIndexSet *)indexes;
- (void)deselectAllItems;

//Basic Cell Information
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfItemsPerRow;
- (NSSize)cellSize;
- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex;
- (NSIndexSet *)indexesOfItemsInRect:(NSRect)aRect;
- (NSUInteger)indexOfItemAtPoint:(NSPoint)p;
- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p;
- (NSViewController *)viewControllerForItemAtIndex:(NSUInteger)index;

- (NSIndexSet *)indexesOfInvisibleViewControllers;
- (NSRange)rangeOfVisibleItems;

//Querying ViewControllers
- (NSIndexSet *)indexesOfViewControllers;
- (NSIndexSet *)indexesOfInvisibleViewControllers;
@end
