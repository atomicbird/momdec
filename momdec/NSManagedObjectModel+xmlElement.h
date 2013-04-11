//
//  NSManagedObjectModel+xmlElement.h
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (xmlElement)

- (NSXMLElement *)xmlElement;

- (NSXMLDocument *)xmlDocument;

+ (NSString *)decompileModelAtPath:(NSString *)modelPath inDirectory:(NSString *)resultDirectoryPath;

@end
