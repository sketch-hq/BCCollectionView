//
//  BCCollectionViewDelegate.h
//  Fontcase
//
//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BCCollectionView;

@protocol BCCollectionViewDelegate <NSObject>
@required
//IconViewa assumes all cells aer the same size and will resize its subviews to this size.
- (NSSize)cellSizeForIconView:(BCCollectionView *)iconView;

//Return an empty ViewController, this might not be visible to the user immediately
- (NSViewController *)reusableViewControllerForIconView:(BCCollectionView *)iconView;

//The IconView is about to display the ViewController. Use this method to populate the ViewController with data
- (void)iconView:(BCCollectionView *)iconView willShowViewController:(NSViewController *)viewController forItem:(id)anItem;
@optional
//the viewController has been removed from view and storen for reuse. You can uload any resources here
- (void)iconView:(BCCollectionView *)iconView viewControllerBecameInvisible:(NSViewController *)viewController;

- (void)iconView:(BCCollectionView *)iconView updateViewControllerAsSelected:(NSViewController *)viewController forItem:(id)item;
- (void)iconView:(BCCollectionView *)iconView updateViewControllerAsDeselected:(NSViewController *)viewController forItem:(id)item;

//managing selections. dont update the viewController do relfect select status. use the methods above instead
- (BOOL)iconView:(BCCollectionView *)iconView shouldSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)iconView:(BCCollectionView *)iconView didSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)iconView:(BCCollectionView *)iconView didDeselectItem:(id)anItem withViewController:(NSViewController *)viewController;

//defaults to YES
- (BOOL)iconViewShouldDrawSelections:(BCCollectionView *)iconView;
@end
