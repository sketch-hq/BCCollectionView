//  Created by Pieter Omvlee on 13/12/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import "BCCollectionView.h"

@interface BCCollectionView (BCCollectionView_Dragging)
- (void)initiateDraggingSessionWithEvent:(NSEvent *)anEvent;

//delegate shortcuts
- (BOOL)delegateSupportsDragForItemsAtIndexes:(NSIndexSet *)indexSet;
- (void)delegateWriteIndexes:(NSIndexSet *)indexSet toPasteboard:(NSPasteboard *)pasteboard;
- (BOOL)delegateCanDrop:(id)draggingInfo onIndex:(NSUInteger)index;
- (void)setDragHoverIndex:(NSInteger)hoverIndex;
@end
