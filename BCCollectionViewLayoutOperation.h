//  Created by Pieter Omvlee on 02/03/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

@class BCCollectionView, BCCollectionViewLayoutItem;

typedef void(^BCCollectionViewLayoutOperationIterator)(BCCollectionViewLayoutItem *layoutItem);

@interface BCCollectionViewLayoutOperation : NSOperation
{
  BCCollectionViewLayoutOperationIterator layoutCallBack;
  dispatch_block_t layoutCompletionBlock;
  BCCollectionView *collectionView;
}
@property (copy) BCCollectionViewLayoutOperationIterator layoutCallBack;
@property (copy) dispatch_block_t layoutCompletionBlock;
@property (assign) BCCollectionView *collectionView;

@end
