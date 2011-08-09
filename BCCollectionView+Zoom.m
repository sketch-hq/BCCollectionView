//  Created by Pieter Omvlee on 02/02/2011.
//  Copyright 2011 Bohemian Coding. All rights reserved.

#import "BCCollectionView+Zoom.h"
#import "BCCollectionViewLayoutManager.h"

@interface BCCollectionView ()
- (void)removeInvisibleViewControllers;
- (void)addMissingViewControllersToView;
@end

@implementation BCCollectionView (BCCollectionView_Zoom)

- (void)registerForZoomValueChangesInDefaultsForKey:(NSString *)key
{
  self.zoomValueObserverKey = key;
  [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:key options:0 context:NULL];
}

- (void)zoomValueDidChange
{
  [self softReloadDataWithCompletionBlock:^{
    if ([delegate respondsToSelector:@selector(colectionViewDidZoom:)])
      [delegate colectionViewDidZoom:self];
  }];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
  [self setAcceptsTouchEvents:YES];
}

- (void)endGestureWithEvent:(NSEvent *)event
{
  [self setAcceptsTouchEvents:NO];
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
  if (!zoomValueObserverKey)
    return;
  
  if (lastPinchMagnification != 0.0)
    [self magnifyWithEvent:event];
}

- (void)magnifyWithEvent:(NSEvent *)event
{
  if (!zoomValueObserverKey)
    return;
  
  CGFloat magnification = [event type] == NSEventTypeMagnify ? [event magnification] : lastPinchMagnification;
  
  CGFloat zoomValue = [[NSUserDefaults standardUserDefaults] integerForKey:zoomValueObserverKey];
  zoomValue = zoomValue * (magnification+1);
  
  NSRange scalingRange = [delegate validScalingRangeForCollectionView:self];
  zoomValue = MAX(MIN(zoomValue, scalingRange.location + scalingRange.length), scalingRange.location);
  [[NSUserDefaults standardUserDefaults] setInteger:zoomValue forKey:zoomValueObserverKey];
  
  [self zoomValueDidChange];
  [[[self enclosingScrollView] contentView] autoscroll:event];
  
  lastPinchMagnification = magnification;
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
  lastPinchMagnification = 0.0; 
}

@end
