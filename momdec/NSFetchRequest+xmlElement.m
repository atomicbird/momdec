//
//  NSFetchRequest+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/10/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSFetchRequest+xmlElement.h"

@implementation NSFetchRequest (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"fetchRequest"];
    [element addAttribute:[NSXMLNode attributeWithName:@"entity" stringValue:[[self entity] name]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"predicateString" stringValue:[[self predicate] predicateFormat]]];
    return element;
}
@end
