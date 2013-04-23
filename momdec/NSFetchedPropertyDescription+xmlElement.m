//
//  NSFetchedPropertyDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/9/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSFetchedPropertyDescription+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"
#import "NSFetchRequest+xmlElement.h"

@implementation NSFetchedPropertyDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [super xmlElement];
    [element setName:@"fetchedProperty"];
    
    NSXMLElement *fetchRequestElement = [[self fetchRequest] xmlElement];
    [fetchRequestElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"fetchedPropertyFetchRequest"]];
    
    [element addChild:fetchRequestElement];
    
    return element;
}

@end
