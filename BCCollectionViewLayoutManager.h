//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>
#import "BCCollectionViewLayoutOperation.h"

@class BCCollectionView;
@interface BCCollectionViewLayoutManager : NSObject
{
  BCCollectionView *collectionView;
  NSOperationQueue *queue;
  
  NSArray *itemLayouts;
}
@property (retain) NSArray *itemLayouts;
- (id)initWithCollectionView:(BCCollectionView *)collectionView; //assigned
- (void)cancelItemEnumerator;
- (void)enumerateItems:(BCCollectionViewLayoutOperationIterator)itemIterator completionBlock:(dispatch_block_t)completionBlock;

#pragma mark Primitives
- (NSUInteger)maximumNumberOfItemsPerRow;
- (NSSize)cellSize;

#pragma mark Rows and Columns
- (NSUInteger)indexOfItemAtRow:(NSUInteger)rowIndex column:(NSUInteger)colIndex;
- (NSPoint)rowAndColumnPositionOfItemAtIndex:(NSUInteger)anIndex;

#pragma mark From Point to Index
- (NSUInteger)indexOfItemAtPoint:(NSPoint)p;
- (NSUInteger)indexOfItemContentRectAtPoint:(NSPoint)p;

#pragma mark From Index to Rect
- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex;
- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex;
@end
