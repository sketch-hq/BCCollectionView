//  Created by Pieter Omvlee on 25/11/2010.
//  Copyright 2010 Bohemian Coding. All rights reserved.

#import <Foundation/Foundation.h>

static NSRect BCRectFromTwoPoints(NSPoint a, NSPoint b)
{
	NSRect  r;
	
	r.size.width = ABS( b.x - a.x );
	r.size.height = ABS( b.y - a.y );
	
	r.origin.x = MIN( a.x, b.x );
	r.origin.y = MIN( a.y, b.y );
  
	return r;
}