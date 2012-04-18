//
//  CellViewController.h
//  Example
//
//  Created by Aaron Brethorst on 5/3/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CellViewController : NSViewController
{
	NSImageView *imageView;
}
@property(nonatomic,retain) IBOutlet NSImageView *imageView;
@end
