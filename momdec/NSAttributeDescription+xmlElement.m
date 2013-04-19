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
    NSXMLElement *element = [super xmlElement];
    [element setName:@"attribute"];
    
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
            case NSBooleanAttributeType:
                defaultValueString = [defaultValue boolValue] ? @"YES" : @"NO";
                break;
            case NSDecimalAttributeType:
            case NSFloatAttributeType:
            case NSDoubleAttributeType:
                defaultValueString = [NSString stringWithFormat:@"%g", [defaultValue doubleValue]];
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
    
    NSArray *validationPredicates = [self validationPredicates];
    for (NSPredicate *validationPredicate in validationPredicates) {
        if ([validationPredicate isKindOfClass:[NSComparisonPredicate class]]) {
            NSComparisonPredicate *comparisonPredicate = (NSComparisonPredicate *)validationPredicate;
            switch ([self attributeType]) {
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                {
                    // Based on observing that integer types have min/max values specified by predicates with format "SELF >= %d" or "SELF <= %d".
                    if ([comparisonPredicate predicateOperatorType] == NSLessThanOrEqualToPredicateOperatorType) {
                        NSNumber *maxValue = [[comparisonPredicate rightExpression] constantValue];
                        [element addAttribute:[NSXMLNode attributeWithName:@"maxValueString" stringValue:[NSString stringWithFormat:@"%ld", [maxValue integerValue]]]];
                    } else if ([comparisonPredicate predicateOperatorType] == NSGreaterThanOrEqualToPredicateOperatorType) {
                        NSNumber *minValue = [[comparisonPredicate rightExpression] constantValue];
                        [element addAttribute:[NSXMLNode attributeWithName:@"minValueString" stringValue:[NSString stringWithFormat:@"%ld", [minValue integerValue]]]];
                    }
                    break;
                }
                case NSDecimalAttributeType:
                case NSDoubleAttributeType:
                case NSFloatAttributeType:
                {
                    // Due to a bug in Xcode, min/max on decimal attributes will fail if the min or max is not an integer.
                    // At compile time, the min and max values are truncated to int values.
                    // See rdar://problem/13677527 or http://openradar.appspot.com/radar?id=2948402
                    // Also, although the attribute is decimal, the min and max values are NSNumber rather than NSDecimalNumber.
                    // This code tries to get the best result by getting doubleValue, but obviously can't put back truncated non-int precision.
                    if ([comparisonPredicate predicateOperatorType] == NSLessThanOrEqualToPredicateOperatorType) {
                        NSNumber *maxValue = [[comparisonPredicate rightExpression] constantValue];
                        [element addAttribute:[NSXMLNode attributeWithName:@"maxValueString" stringValue:[NSString stringWithFormat:@"%g", [maxValue doubleValue]]]];
                    } else if ([comparisonPredicate predicateOperatorType] == NSGreaterThanOrEqualToPredicateOperatorType) {
                        NSNumber *minValue = [[comparisonPredicate rightExpression] constantValue];
                        [element addAttribute:[NSXMLNode attributeWithName:@"minValueString" stringValue:[NSString stringWithFormat:@"%g", [minValue doubleValue]]]];
                    }
                    break;
                }
                    
                    
                default:
                    break;
            }
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
