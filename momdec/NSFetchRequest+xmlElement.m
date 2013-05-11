//
//  NSFetchRequest+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/10/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSFetchRequest+xmlElement.h"

@implementation NSFetchRequest (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"fetchRequest"];
    [element addAttribute:[NSXMLNode attributeWithName:@"entity" stringValue:[[self entity] name]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"predicateString" stringValue:[[self predicate] predicateFormat]]];

    // The following will have no effect on models compiled with Xcode until rdar://problem/13863607 is fixed,
    // because these attributes get stripped out at compile time.
    // Also see http://www.openradar.me/radar?id=3009404
    NSString *resultTypeString = [NSString stringWithFormat:@"%d", NSManagedObjectResultType];
    [element addAttribute:[NSXMLNode attributeWithName:@"resultType" stringValue:resultTypeString]];
    
    NSString *fetchLimitString = [NSString stringWithFormat:@"%ld", (unsigned long)[self fetchLimit]];
    [element addAttribute:[NSXMLNode attributeWithName:@"fetchLimit" stringValue:fetchLimitString]];
    
    NSString *fetchBatchSizeString = [NSString stringWithFormat:@"%ld", (unsigned long)[self fetchBatchSize]];
    [element addAttribute:[NSXMLNode attributeWithName:@"fetchBatchSize" stringValue:fetchBatchSizeString]];
    
    NSString *includesSubentitiesString = [self includesSubentities] ? @"YES" : @"NO";
    [element addAttribute:[NSXMLNode attributeWithName:@"includesSubentities" stringValue:includesSubentitiesString]];
    
    NSString *includePropertyValuesString = [self includesPropertyValues] ? @"YES" : @"NO";
    [element addAttribute:[NSXMLNode attributeWithName:@"includePropertyValues" stringValue:includePropertyValuesString]];
    
    NSString *returnObjectsAsFaultsString = [self returnsObjectsAsFaults] ? @"YES" : @"NO";
    [element addAttribute:[NSXMLNode attributeWithName:@"returnObjectsAsFaults" stringValue:returnObjectsAsFaultsString]];
    
    NSString *includesPendingChangesString = [self includesPendingChanges] ? @"YES" : @"NO";
    [element addAttribute:[NSXMLNode attributeWithName:@"includesPendingChanges" stringValue:includesPendingChangesString]];
    
    NSString *returnsDistinctResultsString = [self returnsDistinctResults] ? @"YES" : @"NO";
    [element addAttribute:[NSXMLNode attributeWithName:@"returnsDistinctResults" stringValue:returnsDistinctResultsString]];
    
    return element;
}
@end
