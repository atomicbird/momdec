//
//  NSAttributeDescription+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSAttributeDescription+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"

@implementation NSAttributeDescription (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element =[[NSXMLElement alloc] initWithName:@"attribute"];
    
    NSMutableDictionary *xmlAttributes = [super commonXMLAttributes];
    
    NSString *attributeTypeString = nil;
    switch ([self attributeType]) {
        case NSInteger16AttributeType:      attributeTypeString = @"Integer 16";    break;
        case NSInteger32AttributeType:      attributeTypeString = @"Integer 32";    break;
        case NSInteger64AttributeType:      attributeTypeString = @"Integer 64";    break;
        case NSBinaryDataAttributeType:     attributeTypeString = @"Binary";        break;
        case NSBooleanAttributeType:        attributeTypeString = @"Boolean";       break;
        case NSDateAttributeType:           attributeTypeString = @"Date";          break;
        case NSDecimalAttributeType:        attributeTypeString = @"Decimal";       break;
        case NSDoubleAttributeType:         attributeTypeString = @"Double";        break;
        case NSFloatAttributeType:          attributeTypeString = @"Float";         break;
        case NSStringAttributeType:         attributeTypeString = @"String";        break;
        case NSTransformableAttributeType:  attributeTypeString = @"Transformable"; break;

        default:                                                                    break;
    }
    if (attributeTypeString != nil) {
        [xmlAttributes setObject:attributeTypeString forKey:@"attributeType"];
    }
    
    id defaultValue = [self defaultValue];
    if (defaultValue != nil) {
        NSString *defaultValueString = nil;
        switch ([self attributeType]) {
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSDateAttributeType:
            case NSDecimalAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%ld", (long)[defaultValue integerValue]];
                break;
            case NSBooleanAttributeType:
                defaultValueString = [defaultValue boolValue] ? @"YES" : @"NO";
                break;
            case NSDoubleAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%f", [defaultValue doubleValue]];
                break;
            case NSFloatAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%f", [defaultValue floatValue]];
                break;
            case NSStringAttributeType:
                defaultValueString = defaultValue;
            default:
                break;
        }
        if (defaultValueString != nil) {
            [xmlAttributes setObject:defaultValueString forKey:@"defaultValueString"];
        }
    }
    
    if ([self allowsExternalBinaryDataStorage]) {
        [xmlAttributes setObject:@"YES" forKey:@"allowsExternalBinaryDataStorage"];
    }

    NSXMLElement *userInfoElement = [self userInfoElement];
    if (userInfoElement != nil) {
        [element addChild:userInfoElement];
    }

    [element setAttributesWithDictionary:xmlAttributes];

    return element;
}
@end
