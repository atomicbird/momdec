//
//  NSManagedObjectModel+xmlElement.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "NSManagedObjectModel+xmlElement.h"
#import "NSEntityDescription+xmlElement.h"
#import "NSFetchRequest+xmlElement.h"

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
    
    // Entities
    for (NSEntityDescription *entityDescription in [self entities]) {
        NSXMLElement *entityElement = [entityDescription xmlElement];
        [element addChild:entityElement];
    }
    // Fetch request templates
    NSDictionary *fetchRequestTemplatesByName = [self fetchRequestTemplatesByName];
    for (NSString *fetchRequestName in fetchRequestTemplatesByName) {
        NSFetchRequest *fetchRequest = fetchRequestTemplatesByName[fetchRequestName];
        NSXMLElement *fetchRequestElement = [fetchRequest xmlElement];
        [fetchRequestElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:fetchRequestName]];
        [element addChild:fetchRequestElement];
    }
    // Configurations
    for (NSString *configurationName in [self configurations]) {
        NSXMLElement *configurationElement = [[NSXMLElement alloc] initWithName:@"configuration"];
        [element addChild:configurationElement];
        [configurationElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:configurationName]];
        NSArray *entitiesForConfiguration = [self entitiesForConfiguration:configurationName];
        for (NSEntityDescription *entity in entitiesForConfiguration) {
            NSXMLElement *entityElement = [[NSXMLElement alloc] initWithName:@"memberEntity"];
            [configurationElement addChild:entityElement];
            [entityElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[entity name]]];
        }
    }
    
    // Empty "elements" (used to store locations for graphical model editor)
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

+ (NSString *)_decompileSingleModelFile:(NSString *)momPath inDirectory:(NSString *)resultDirectoryPath
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
        xcdatamodelPath = [resultDirectoryPath stringByAppendingPathComponent:[[[momPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"]];
        [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodelPath withIntermediateDirectories:YES attributes:0 error:nil];
        NSString *modelXMLPath = [xcdatamodelPath stringByAppendingPathComponent:@"contents"];
        [modelXMLData writeToFile:modelXMLPath atomically:YES];
    }
    return xcdatamodelPath;
}

+ (NSString *)_decompileModelBundleAtPath:(NSString *)momdPath inDirectory:(NSString *)resultDirectoryPath
{
    BOOL isDirectory;
    NSString *xcdatamodeldPath = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:momdPath isDirectory:&isDirectory] && isDirectory) {
        // Create a new xcdatamodeld container
        xcdatamodeldPath = [resultDirectoryPath stringByAppendingPathComponent:[[[momdPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodeld"]];
        [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodeldPath withIntermediateDirectories:YES attributes:0 error:nil];
        
        NSArray *momdContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:momdPath error:nil];
        for (NSString *filename in momdContents) {
            NSString *fullPath = [momdPath stringByAppendingPathComponent:filename];
            if ([filename hasSuffix:@".mom"]) {
                // Process each model in the momd
                [NSManagedObjectModel _decompileSingleModelFile:fullPath inDirectory:xcdatamodeldPath];
            } else if ([filename isEqualToString:@"VersionInfo.plist"]) {
                // Process version info for the momd
                NSDictionary *versionInfo = [NSDictionary dictionaryWithContentsOfFile:fullPath];
                NSString *currentVersionName = versionInfo[@"NSManagedObjectModel_CurrentVersionName"];
                if (currentVersionName != nil) {
                    NSString *currentModelName = [currentVersionName stringByAppendingPathExtension:@"xcdatamodel"];
                    NSDictionary *versionDictionary = @{@"_XCCurrentVersionName": currentModelName};
                    [versionDictionary writeToFile:[xcdatamodeldPath stringByAppendingPathComponent:@".xccurrentversion"] atomically:YES];
                }
            }
        }
    }
    return xcdatamodeldPath;
}

+ (NSString *)_decompileAppBundleAtPath:(NSString *)appBundlePath inDirectory:(NSString *)resultDirectoryPath
{
    BOOL isDirectory;
    NSString *xcModelPath = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:appBundlePath isDirectory:&isDirectory] && isDirectory) {
        // Find the first mom or momd in the app bundle, decompile it and return.
        NSDirectoryEnumerator *appBundleEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:appBundlePath];
        NSString *currentPath;
        while (((currentPath = [appBundleEnumerator nextObject])) && (xcModelPath == nil)) {
            if ([currentPath hasSuffix:@".mom"]) {
                NSString *fullPath = [appBundlePath stringByAppendingPathComponent:currentPath];
                xcModelPath = [NSManagedObjectModel _decompileSingleModelFile:fullPath inDirectory:resultDirectoryPath];
            } else if ([currentPath hasSuffix:@".momd"]) {
                NSString *fullPath = [appBundlePath stringByAppendingPathComponent:currentPath];
                xcModelPath = [NSManagedObjectModel _decompileModelBundleAtPath:fullPath inDirectory:resultDirectoryPath];
            }
        }
    }
    if (xcModelPath == nil) {
        NSLog(@"Could not find a compiled model in %@", appBundlePath);
    }
    return xcModelPath;
}

+ (NSString *)decompileModelAtPath:(NSString *)modelPath inDirectory:(NSString *)resultDirectoryPath
{
    modelPath = [modelPath stringByStandardizingPath];
    if ([modelPath hasSuffix:@".mom"]) {
        return [NSManagedObjectModel _decompileSingleModelFile:modelPath inDirectory:resultDirectoryPath];
    } else if ([modelPath hasSuffix:@".momd"]) {
        return [NSManagedObjectModel _decompileModelBundleAtPath:modelPath inDirectory:resultDirectoryPath];
    } else if ([modelPath hasSuffix:@".app"]) {
        return [NSManagedObjectModel _decompileAppBundleAtPath:modelPath inDirectory:resultDirectoryPath];
    } else {
        NSLog(@"Unrecognized file: %@", modelPath);
        return nil;
    }
}
@end
