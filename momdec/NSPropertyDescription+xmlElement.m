//
//  NSPropertyDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSPropertyDescription+xmlElement.h"

@implementation NSPropertyDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    return nil;
}

- (void)addCommonXMLDataToElement:(NSXMLElement *)element
{
    [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self name]]];
    if ([self isOptional]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"optional" stringValue:@"YES"]];
    }
    if ([self isTransient]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"transient" stringValue:@"YES"]];
    }
    if ([self isIndexed]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"indexed" stringValue:@"YES"]];
    }
    
    NSDictionary *userInfo = [self userInfo];
    if ([userInfo count] > 0) {
        NSXMLElement *userInfoElement = [[NSXMLElement alloc] initWithName:@"userInfo"];
        for (NSString *userInfoKey in userInfo) {
            NSXMLElement *userInfoEntry = [[NSXMLElement alloc] initWithName:@"entry"];
            NSDictionary *userInfoAttributes = @{@"key" : userInfoKey, @"value" : [userInfo objectForKey:userInfoKey]};
            [userInfoEntry setAttributesWithDictionary:userInfoAttributes];
            [userInfoElement addChild:userInfoEntry];
        }
        [element addChild:userInfoElement];
    }
}

@end
