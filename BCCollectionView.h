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
  
  NSPoint mouseDownLocation;
  NSPoint mouseDraggedLocation;
  
  NSColor *backgroundColor;
  
  NSUInteger lastSelectionIndex;
}
@property (nonatomic, assign) id<BCCollectionViewDelegate> delegate;
@property (nonatomic, retain) NSColor *backgroundColor;

//by setting the contentArray, the view will load itself up.
@property (nonatomic, copy) NSArray *contentArray;

//private
@property (nonatomic, copy) NSIndexSet *originalSelectionIndexes;
@property (nonatomic) NSUInteger lastSelectionIndex;

- (void)reloadData;

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

//Querying ViewControllers
- (NSIndexSet *)indexesOfViewControllers;
- (NSIndexSet *)indexesOfInvisibleViewControllers;
@end
