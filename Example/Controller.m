//
//  Controller.m
//  Example
//
//  Created by Aaron Brethorst on 5/3/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import "Controller.h"
#import "CellViewController.h"

@implementation Controller
@synthesize collectionView;
@synthesize imageContent;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	imageContent = [[NSMutableArray alloc] init];
	[imageContent addObject:[NSImage imageNamed:NSImageNameQuickLookTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameBluetoothTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameIChatTheaterTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameActionTemplate]]; 
	[imageContent addObject:[NSImage imageNamed:NSImageNameSmartBadgeTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameIconViewTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameListViewTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameColumnViewTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFlowViewTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNamePathTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameInvalidDataFreestandingTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameLockLockedTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameLockUnlockedTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameGoRightTemplate]]; 
	[imageContent addObject:[NSImage imageNamed:NSImageNameGoLeftTemplate]]; 
	[imageContent addObject:[NSImage imageNamed:NSImageNameRightFacingTriangleTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameLeftFacingTriangleTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameAddTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameRemoveTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameRevealFreestandingTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameEnterFullScreenTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameExitFullScreenTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStopProgressTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameRefreshTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameBonjour]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameComputer]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFolderBurnable]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFolderSmart]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFolder]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameNetwork]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameDotMac]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameMobileMe]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameMultipleDocuments]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameUserAccounts]];
	[imageContent addObject:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameAdvanced]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameInfo]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameFontPanel]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameColorPanel]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameUser]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameUserGroup]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameEveryone]];  
	[imageContent addObject:[NSImage imageNamed:NSImageNameUserGuest]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameMenuOnStateTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameMenuMixedStateTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameApplicationIcon]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameTrashEmpty]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameTrashFull]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameHomeTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameBookmarksTemplate]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameCaution]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStatusAvailable]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStatusPartiallyAvailable]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStatusUnavailable]];
	[imageContent addObject:[NSImage imageNamed:NSImageNameStatusNone]];
	
	[self.collectionView reloadDataWithItems:imageContent emptyCaches:NO];
}

#pragma mark -
#pragma mark BCCollectionViewDelegate

//CollectionView assumes all cells are the same size and will resize its subviews to this size.
- (NSSize)cellSizeForCollectionView:(BCCollectionView *)collectionView
{
	return NSMakeSize(64, 64);
}

//Return an empty ViewController, this might not be visible to the user immediately
- (NSViewController *)reusableViewControllerForCollectionView:(BCCollectionView *)collectionView
{
	return [[[CellViewController alloc] init] autorelease];
}

//The CollectionView is about to display the ViewController. Use this method to populate the ViewController with data
- (void)collectionView:(BCCollectionView *)collectionView willShowViewController:(NSViewController *)viewController forItem:(id)anItem
{
	CellViewController *cell = (CellViewController*)viewController;
	[cell.imageView setImage:anItem];
}

@end