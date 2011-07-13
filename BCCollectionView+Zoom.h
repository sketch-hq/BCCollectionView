//  Created by Pieter Omvlee on 02/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>
#import "BCCollectionView.h"

@interface BCCollectionView (BCCollectionView_Zoom)
- (void)registerForZoomValueChangesInDefaultsForKey:(NSString *)key;
@end
