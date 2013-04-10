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
    [element setAttributesWithDictionary:@{
     @"name": @"",
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
    NSXMLElement *editorLayoutNode = [[NSXMLElement alloc] initWithName:@"elements"];
    [element addChild:editorLayoutNode];
    
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

+ (NSString *)_decompileSingleModelFile:(NSString *)momPath
{
    NSData *modelXMLData = nil;
    NSString *xcdatamodelPath = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:momPath]) {
        NSManagedObjectModel *model = nil;
        @try {
            model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momPath]];
        }
        @catch (NSException *exception) {
            NSLog(@"Couldn't open model file %@", momPath);
        }
        @finally {
            
        }
        
        if (model != nil) {
            NSXMLDocument *modelDocument = [model xmlDocument];
            modelXMLData = [modelDocument XMLDataWithOptions:NSXMLNodePrettyPrint|NSXMLNodeCompactEmptyElement|NSXMLDocumentIncludeContentTypeDeclaration];
        }
    }
    
    if (modelXMLData != nil) {
        xcdatamodelPath = [[[momPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"];
        [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodelPath withIntermediateDirectories:YES attributes:0 error:nil];
        NSString *modelXMLPath = [xcdatamodelPath stringByAppendingPathComponent:@"contents"];
        [modelXMLData writeToFile:modelXMLPath atomically:YES];
    }
    return xcdatamodelPath;
}

+ (NSString *)_decompileModelBundleAtPath:(NSString *)momdPath
{
    BOOL isDirectory;
    NSString *xcdatamodeldPath = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:momdPath isDirectory:&isDirectory] && isDirectory) {
        // Create a new xcdatamodeld container
        xcdatamodeldPath = [[[momdPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodeld"];
        [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodeldPath withIntermediateDirectories:YES attributes:0 error:nil];
        chdir([xcdatamodeldPath fileSystemRepresentation]);
        
        NSArray *momdContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:momdPath error:nil];
        for (NSString *filename in momdContents) {
            NSString *fullPath = [momdPath stringByAppendingPathComponent:filename];
            if ([filename hasSuffix:@".mom"]) {
                // Process each model in the momd
                [NSManagedObjectModel _decompileSingleModelFile:fullPath];
            } else if ([filename isEqualToString:@"VersionInfo.plist"]) {
                // Process version info for the momd
                NSDictionary *versionInfo = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                NSString *currentVersionName = [versionInfo objectForKey:@"NSManagedObjectModel_CurrentVersionName"];
                NSString *currentModelName = [currentVersionName stringByAppendingPathExtension:@"xcdatamodel"];
                NSDictionary *versionDictionary = @{@"_XCCurrentVersionName": currentModelName};
                [versionDictionary writeToFile:@".xccurrentversion" atomically:YES];
            }
        }
    }
    return xcdatamodeldPath;
}

+ (NSString *)decompileModelAtPath:(NSString *)modelPath
{
    if ([modelPath hasSuffix:@".mom"]) {
        return [NSManagedObjectModel _decompileSingleModelFile:modelPath];
    } else if ([modelPath hasSuffix:@".momd"]) {
        return [NSManagedObjectModel _decompileModelBundleAtPath:modelPath];
    } else {
        NSLog(@"Unrecognized file: %@", modelPath);
        return nil;
    }
}
@end
