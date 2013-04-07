//
//  NSManagedObjectModel+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSManagedObjectModel+xmlElement.h"
#import "NSEntityDescription+xmlElement.h"

@implementation NSManagedObjectModel (xmlElement)

- (NSXMLElement *)xmlElement
{
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"model"];

    // Skipped attributes (for now?):
    // lastSavedToolsVersion
    // systemVersion
    [element setAttributesWithDictionary:@{@"name": @"",
     @"userDefinedModelVersionIdentifier": @"",
     @"type": @"com.apple.IDECoreDataModeler.DataModel",
     @"documentVersion": @"1.0",
     @"minimumToolsVersion": @"Automatic",
     @"macOSVersion": @"Automatic",
     @"iOSVersion" : @"Automatic"
     }];
    for (NSEntityDescription *entityDescription in [self entities]) {
        NSXMLElement *entityElement = [entityDescription xmlElement];
        [element addChild:entityElement];
    }
    return element;
}

- (NSXMLDocument *)xmlDocument
{
    NSXMLDocument *modelDocument = [[NSXMLDocument alloc] initWithRootElement:[self xmlElement]];
    [modelDocument setDocumentContentKind:NSXMLDocumentXMLKind];
    [modelDocument setCharacterEncoding:@"UTF-8"];
    [modelDocument setVersion:@"1.0"];
    [modelDocument setStandalone:YES];
    return modelDocument;
}
@end
