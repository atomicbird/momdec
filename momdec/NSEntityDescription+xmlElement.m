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
    NSMutableDictionary *xmlAttributes = [NSMutableDictionary dictionary];
    [xmlAttributes setObject:[self name] forKey:@"name"];
    [xmlAttributes setObject:[self managedObjectClassName] forKey:@"representedClassName"];
    if ([self superentity] != nil) {
        [xmlAttributes setObject:[[self superentity] name] forKey:@"parentEntity"];
    }
    if ([self isAbstract]) {
        [xmlAttributes setObject:@"YES" forKey:@"isAbstract"];
    }
    [element setAttributesWithDictionary:xmlAttributes];
    
    // Add children for entity attributes.
    for (NSPropertyDescription *propertyDescription in [self properties]) {
        [element addChild:[propertyDescription xmlElement]];
    }
    
    return element;
}

@end
