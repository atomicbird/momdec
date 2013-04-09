//
//  NSFetchedPropertyDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/9/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSFetchedPropertyDescription+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"

@implementation NSFetchedPropertyDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"fetchedProperty"];
    [self addCommonXMLDataToElement:element];
    
    NSXMLElement *fetchRequestElement = [[NSXMLElement alloc] initWithName:@"fetchRequest"];
    NSString *predicateString = [[[self fetchRequest] predicate] predicateFormat];
    [fetchRequestElement addAttribute:[NSXMLNode attributeWithName:@"predicateString" stringValue:predicateString]];
    [fetchRequestElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"fetchedPropertyFetchRequest"]];
    [fetchRequestElement addAttribute:[NSXMLNode attributeWithName:@"entity" stringValue:[[self fetchRequest] entityName]]];
    
    [element addChild:fetchRequestElement];
    
    return element;
}

@end
