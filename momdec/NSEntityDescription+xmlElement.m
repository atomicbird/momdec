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
    NSString *representedClassName = [self managedObjectClassName];
    if (![representedClassName isEqualToString:@"NSManagedObject"]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"representedClassName" stringValue:representedClassName]];
    }
    if ([self superentity] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"parentEntity" stringValue:[[self superentity] name]]];
    }
    if ([self isAbstract]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"isAbstract" stringValue:@"YES"]];
    }

    NSDictionary *userInfo = [self userInfo];
    NSString *syncable = [userInfo objectForKey:@"com.apple.syncservices.Syncable"];
    if ((syncable == nil) || ((syncable != nil) && (![syncable isEqualToString:@"NO"]))) {
        [element addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    }

    if ([userInfo count] > 0) {
        NSXMLElement *userInfoElement = [[NSXMLElement alloc] initWithName:@"userInfo"];
        for (NSString *userInfoKey in userInfo) {
            NSString *userInfoValue = [userInfo objectForKey:userInfoKey];
            if ([userInfoKey isEqualToString:@"com.apple.syncservices.Syncable"]) {
                // This key should never appear in uncompiled models.
            } else {
                NSXMLElement *userInfoEntry = [[NSXMLElement alloc] initWithName:@"entry"];
                NSDictionary *userInfoAttributes = @{@"key" : userInfoKey, @"value" : userInfoValue};
                [userInfoEntry setAttributesWithDictionary:userInfoAttributes];
                [userInfoElement addChild:userInfoEntry];
            }
        }
        [element addChild:userInfoElement];
    }

    if ([self versionHashModifier] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"versionHashModifier" stringValue:[self versionHashModifier]]];
    }
    if ([self renamingIdentifier] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"elementID" stringValue:[self renamingIdentifier]]];
    }
    // Add children for entity attributes.
    for (NSPropertyDescription *propertyDescription in [self properties]) {
        [element addChild:[propertyDescription xmlElement]];
    }
    
    return element;
}

@end
