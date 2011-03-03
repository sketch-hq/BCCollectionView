//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView.h"

@interface BCCollectionView (BCCollectionView_Keyboard)
- (void)keyDown:(NSEvent *)theEvent;

- (void)moveLeft:(id)sender;
- (void)moveLeftAndModifySelection:(id)sender;

- (void)moveRight:(id)sender;
- (void)moveRightAndModifySelection:(id)sender;

- (void)moveUp:(id)sender;
- (void)moveUpAndModifySelection:(id)sender;

- (void)moveDown:(id)sender;
- (void)moveDownAndModifySelection:(id)sender;
@end

@interface NSIndexSet (BCCollectionView_IndexSet)
- (NSIndexSet *)indexSetByRemovingIndex:(NSUInteger)index;
@end