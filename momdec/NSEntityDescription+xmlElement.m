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
    // There's some funky shit related to the com.apple.syncservices.Syncable userInfo key.
    // If com.apple.syncservices.Syncable was not present in Xcode:
    //      There's no sign of it here. Write syncable=YES as an attribute.
    // If com.apple.syncservices.Syncable was present in Xcode and equal to NO:
    //      It will be present in self's userInfo. Don't write it to userInfo, but don't write syncable=YES either. DO write an empty userInfo if needed.
    // If com.apple.syncservices.Syncable was present in Xcode and equal to YES:
    //      There's no sign of it here. The original uncompiled model will have contained an empty <userInfo> element, but
    //      it's impossible to know that we should add one here. Write syncable=YES as an attribute.
    //      THIS MEANS UNIT TESTS WILL FAIL, but there's nothing that can be done about it because the data doesn't exist.
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

    // Add children for entity attributes.
    for (NSPropertyDescription *propertyDescription in [self properties]) {
        [element addChild:[propertyDescription xmlElement]];
    }
    
    return element;
}

@end
