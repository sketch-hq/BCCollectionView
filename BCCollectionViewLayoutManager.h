//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@class BCCollectionView;
@interface BCCollectionViewLayoutManager : NSObject
{
  BCCollectionView *collectionView;
  NSInteger numberOfRows;
  NSArray *groups;
  NSMutableArray *itemLayouts;
  
  NSOperationQueue *queue;
}
@property (copy) NSArray *groups;
- (id)initWithCollectionView:(BCCollectionView *)collectionView; //assigned
- (void)reloadWithCompletionBlock:(dispatch_block_t)completionBlock;

#pragma mark Primitives
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfItemsAtRow:(NSInteger)rowIndex;
- (NSSize)cellSize;

#pragma mark From Point to Index
- (NSUInteger)indexOfItemAtPoint:(NSPoint)p;
- (NSUInteger)indexOfItemContentRectAtPoint:(NSPoint)p;

#pragma mark From Index to Rect
- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex;
- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex;
@end
