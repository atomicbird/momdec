//
//  NSRelationshipDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSRelationshipDescription+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"

@implementation NSRelationshipDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"relationship"];
    [self addCommonXMLDataToElement:element];
    
    if ([self minCount]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"minCount" stringValue:[NSString stringWithFormat:@"%ld", (unsigned long)[self minCount]]]];
    }
    if ([self maxCount]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"maxCount" stringValue:[NSString stringWithFormat:@"%ld", (unsigned long)[self maxCount]]]];
    }

    NSString *deleteRuleString = nil;
    switch ([self deleteRule]) {
        case NSNullifyDeleteRule:   deleteRuleString = @"Nullify";  break;
        case NSCascadeDeleteRule:   deleteRuleString = @"Cascade";  break;
        case NSDenyDeleteRule:      deleteRuleString = @"Deny";     break;
        default:                                                    break;
    }
    if (deleteRuleString != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"deletionRule" stringValue:deleteRuleString]];
    }

    [element addAttribute:[NSXMLNode attributeWithName:@"destinationEntity" stringValue:[[self destinationEntity] name]]];
    if ([self inverseRelationship] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"inverseName" stringValue:[[self inverseRelationship] name]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"inverseEntity" stringValue:[[[self inverseRelationship] entity] name]]];
    }
    
    return element;
}
@end
