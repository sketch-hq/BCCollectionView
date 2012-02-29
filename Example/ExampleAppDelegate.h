//
//  ExampleAppDelegate.h
//  Example
//
//  Created by Aaron Brethorst on 5/3/11.
//  Copyright 2011 Structlab LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ExampleAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
