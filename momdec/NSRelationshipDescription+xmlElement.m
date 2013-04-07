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
    
    NSMutableDictionary *xmlAttributes = [super commonXMLAttributes];
    if ([self minCount]) {
        [xmlAttributes setObject:[NSString stringWithFormat:@"%ld", (unsigned long)[self minCount]] forKey:@"minCount"];
    }
    if ([self maxCount]) {
        [xmlAttributes setObject:[NSString stringWithFormat:@"%ld", (unsigned long)[self maxCount]] forKey:@"maxCount"];
    }

    NSString *deleteRuleString = nil;
    switch ([self deleteRule]) {
        case NSNullifyDeleteRule:   deleteRuleString = @"Nullify";  break;
        case NSCascadeDeleteRule:   deleteRuleString = @"Cascade";  break;
        case NSDenyDeleteRule:      deleteRuleString = @"Deny";     break;
        default:                                                    break;
    }
    if (deleteRuleString != nil) {
        [xmlAttributes setObject:deleteRuleString forKey:@"deletionRule"];
    }

    [xmlAttributes setObject:[[self destinationEntity] name] forKey:@"destinationEntity"];
    if ([self inverseRelationship] != nil) {
        [xmlAttributes setObject:[[self inverseRelationship] name] forKey:@"inverseName"];
        [xmlAttributes setObject:[[[self inverseRelationship] entity] name] forKey:@"inverseEntity"];
    }
    
    NSXMLElement *userInfoElement = [self userInfoElement];
    if (userInfoElement != nil) {
        [element addChild:userInfoElement];
    }

    [element setAttributesWithDictionary:xmlAttributes];
    return element;
}
@end
