//
//  NSEntityDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSEntityDescription+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"

@implementation NSEntityDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"entity"];

    // Set up XML attributes for self
    [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self name]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"representedClassName" stringValue:[self managedObjectClassName]]];
    if ([self superentity] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"parentEntity" stringValue:[[self superentity] name]]];
    }
    if ([self isAbstract]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"isAbstract" stringValue:@"YES"]];
    }
    
    // Add children for entity attributes.
    for (NSPropertyDescription *propertyDescription in [self properties]) {
        [element addChild:[propertyDescription xmlElement]];
    }
    
    return element;
}

@end
