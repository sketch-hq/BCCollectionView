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
//CollectionView assumes all cells aer the same size and will resize its subviews to this size.
- (NSSize)cellSizeForCollectionView:(BCCollectionView *)collectionView;

//Return an empty ViewController, this might not be visible to the user immediately
- (NSViewController *)reusableViewControllerForCollectionView:(BCCollectionView *)collectionView;

//The CollectionView is about to display the ViewController. Use this method to populate the ViewController with data
- (void)collectionView:(BCCollectionView *)collectionView willShowViewController:(NSViewController *)viewController forItem:(id)anItem;

@optional
//the viewController has been removed from view and storen for reuse. You can uload any resources here
- (void)collectionView:(BCCollectionView *)collectionView viewControllerBecameInvisible:(NSViewController *)viewController;

- (void)collectionView:(BCCollectionView *)collectionView updateViewControllerAsSelected:(NSViewController *)viewController forItem:(id)item;
- (void)collectionView:(BCCollectionView *)collectionView updateViewControllerAsDeselected:(NSViewController *)viewController forItem:(id)item;

//managing selections. dont update the viewController do relfect select status. use the methods above instead
- (BOOL)collectionView:(BCCollectionView *)collectionView shouldSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView didSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
- (void)collectionView:(BCCollectionView *)collectionView didDeselectItem:(id)anItem withViewController:(NSViewController *)viewController;

- (void)collectionViewDidScroll:(BCCollectionView *)collectionView;
- (void)collectionView:(BCCollectionView *)collectionView didDoubleClickViewControllerAtIndex:(NSViewController *)viewController;

//defaults to YES
- (BOOL)collectionViewShouldDrawSelections:(BCCollectionView *)collectionView;
@end
