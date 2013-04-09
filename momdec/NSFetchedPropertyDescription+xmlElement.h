//
//  NSFetchedPropertyDescription+xmlElement.h
//  momdec
//
//  Created by Tom Harrington on 4/9/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSFetchedPropertyDescription (xmlElement)

- (NSXMLElement *)xmlElement;

@end
