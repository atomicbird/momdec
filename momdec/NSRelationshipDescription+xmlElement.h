//
//  NSRelationshipDescription+xmlElement.h
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSRelationshipDescription (xmlElement)

- (NSXMLElement *)xmlElement;

@end
