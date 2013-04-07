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

- (NSMutableDictionary *)commonXMLAttributes
{
    NSMutableDictionary *xmlAttributes = [NSMutableDictionary dictionary];
    [xmlAttributes setObject:[self name] forKey:@"name"];
    
    if ([self isOptional]) {
        [xmlAttributes setObject:@"YES" forKey:@"optional"];
    }
    if ([self isTransient]) {
        [xmlAttributes setObject:@"YES" forKey:@"transient"];
    }
    if ([self isIndexed]) {
        [xmlAttributes setObject:@"YES" forKey:@"indexed"];
    }
    return xmlAttributes;
}

- (NSXMLElement *)userInfoElement
{
    NSDictionary *userInfo = [self userInfo];
    NSXMLElement *userInfoElement = nil;
    if ([userInfo count] > 0) {
        userInfoElement = [[NSXMLElement alloc] initWithName:@"userInfo"];
        for (NSString *userInfoKey in userInfo) {
            NSXMLElement *userInfoEntry = [[NSXMLElement alloc] initWithName:@"entry"];
            NSDictionary *userInfoAttributes = @{@"key" : userInfoKey, @"value" : [userInfo objectForKey:userInfoKey]};
            [userInfoEntry setAttributesWithDictionary:userInfoAttributes];
            [userInfoElement addChild:userInfoEntry];
        }
    }
    return userInfoElement;
}
@end
