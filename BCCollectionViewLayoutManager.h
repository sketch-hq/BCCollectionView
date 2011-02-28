//  Created by Pieter Omvlee on 15/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@class BCCollectionView;
@interface BCCollectionViewLayoutManager : NSObject
{
  BCCollectionView *collectionView;
  NSInteger numberOfRows;
}
- (id)initWithCollectionView:(BCCollectionView *)collectionView; //assigned

- (void)willReload;
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfItemsAtRow:(NSInteger)rowIndex;
- (NSUInteger)rowOfItemAtIndex:(NSInteger)anIndex;
- (NSSize)cellSize;
- (NSUInteger)indexOfItemAtPointOrClosestGuess:(NSPoint)p;

- (NSRect)rectOfItemAtIndex:(NSUInteger)anIndex;
- (NSRect)contentRectOfItemAtIndex:(NSUInteger)anIndex;

- (NSUInteger)indexOfItemAtPoint:(NSPoint)p;
- (NSUInteger)indexOfItemContentRectAtPoint:(NSPoint)p;
@end
