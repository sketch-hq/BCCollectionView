# BCCollectionView

BCCollectionView is intended as a replacement for NSCollectionView (and possibly IKImageBrowserView). It is designed to work with a lot of items and only loads the views that it actually needs.

Unlike NSCollectionView, BCCollectionView smoothly displays 300.000+ items.
Every 'cell' in an BCCollectionView is an NSViewController. At the moment these are only uniform; every cell is supposed to be the same NSViewController subclass.

# High-level concept overview of BCCollectionView

- The delegate provides empty NSViewControllers for the BCCollectionView that will be reused as often as needed; you can already style the view in it to a creation degree but the delegate doesn't know yet which item it will be displaying later.

	- (NSViewController *)reusableViewControllerForIconView:(BCCollectionView *)iconView

- Before BCCollectionView shows them, it asks the delegate to populate an NSViewController with an item from its contentArray; this is the time to set labels or images that are dependent on the item its supposed to represent

	- (void)iconView:(BCCollectionView *)iconView willShowViewController:(NSViewController *)viewController forItem:(id)anItem

- When the user scrolls the view, some views will become invisible. BCCollectionView removes them from  view and stores them for later use. The delegate has a chance to unload any item-specific resources the item, possibly to save memory for example or do other kinds of cleanup

	- (void)iconView:(BCCollectionView *)iconView viewControllerBecameInvisible:(NSViewController *)viewController

- If the categories on BCCollectionView are included too, the users can use either mouse or keyboard to select items. By default, BCCollectionView will (for now) just draw a rather ugly bezel under a view if it is selected. The delegate can customise this behaviour by return NO in:

	- (BOOL)iconViewShouldDrawSelections:(BCCollectionView *)iconView

If the delegate also overrides the following two methods it can customise its view to determine how to show a selected item instead:

	- (void)iconView:(BCCollectionView *)iconView updateViewControllerAsSelected:(NSViewController *)viewController forItem:(id)item;
	- (void)iconView:(BCCollectionView *)iconView updateViewControllerAsDeselected:(NSViewController *)viewController forItem:(id)item;

Note. Do not use the following methods to style viewControllers. They are intended to inform the delegates of changes in the selection. Using these methods to style the viewControllers might break when the views are being reused at a later point.

	- (BOOL)iconView:(BCCollectionView *)iconView shouldSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
	- (void)iconView:(BCCollectionView *)iconView didSelectItem:(id)anItem withViewController:(NSViewController *)viewController;
	- (void)iconView:(BCCollectionView *)iconView didDeselectItem:(id)anItem withViewController:(NSViewController *)viewController;

# Groups

The latest addition to BCCollectionView has to with groups. Just like IKImageBrowserView, we can now divide the items into groups. A group is simply a range with a title, and the delegate can supply a custom NSViewController to represent the header.
Groups can be set using the default way to load the BCCollectionView:

	- (void)reloadDataWithItems:(NSArray *)newContent groups:(NSArray *)newGroups emptyCaches:(BOOL)shouldEmptyCaches;

# License

BCCollectionView is licensed under the BSD license