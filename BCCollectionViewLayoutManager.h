//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@class BCCollectionView;
@interface BCCollectionViewLayoutManager : NSObject
{
  BCCollectionView *collectionView;
  NSOperationQueue *queue;
  
  NSMutableArray *itemLayouts;
  NSInteger numberOfRows;  
}
@property (readonly) NSArray *itemLayouts;
- (id)initWithCollectionView:(BCCollectionView *)collectionView; //assigned
- (void)reloadWithCompletionBlock:(dispatch_block_t)completionBlock;

#pragma mark Primitives
- (NSUInteger)numberOfRows;
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
