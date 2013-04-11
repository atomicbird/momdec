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
    [self addCommonXMLDataToElement:element];
    
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
        [element addAttribute:[NSXMLNode attributeWithName:@"attributeType" stringValue:attributeTypeString]];
    }
    
    id defaultValue = [self defaultValue];
    if (defaultValue != nil) {
        NSString *defaultValueString = nil;
        switch ([self attributeType]) {
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
                defaultValueString = [NSString stringWithFormat:@"%ld", (long)[defaultValue integerValue]];
                break;
            case NSDecimalAttributeType:
                defaultValueString = [defaultValue descriptionWithLocale:nil];
                break;
            case NSBooleanAttributeType:
                defaultValueString = [defaultValue boolValue] ? @"YES" : @"NO";
                break;
            case NSDoubleAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%g", [defaultValue doubleValue]];
                break;
            case NSFloatAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%g", [defaultValue floatValue]];
                break;
            case NSStringAttributeType:
                defaultValueString = defaultValue;
                break;
            case NSDateAttributeType:
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZZ"];
                defaultValueString = [formatter stringFromDate:defaultValue];
                NSTimeInterval defaultDateTimeInterval = [defaultValue timeIntervalSinceReferenceDate];
                [element addAttribute:[NSXMLNode attributeWithName:@"defaultDateTimeInterval" stringValue:[NSString stringWithFormat:@"%.0f", defaultDateTimeInterval]]];
                break;
            }
            default:
                break;
        }
        if (defaultValueString != nil) {
            [element addAttribute:[NSXMLNode attributeWithName:@"defaultValueString" stringValue:defaultValueString]];
        }
    }
    
    if ([self valueTransformerName] != nil) {
        [element addAttribute:[NSXMLNode attributeWithName:@"valueTransformerName" stringValue:[self valueTransformerName]]];
    }
    if ([self allowsExternalBinaryDataStorage]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"allowsExternalBinaryDataStorage" stringValue:@"YES"]];
    }
    if ([self isIndexedBySpotlight]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"spotlightIndexingEnabled" stringValue:@"YES"]];
    }
    if ([self isStoredInExternalRecord]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"storedInTruthFile" stringValue:@"YES"]];
    }

    return element;
}
@end
