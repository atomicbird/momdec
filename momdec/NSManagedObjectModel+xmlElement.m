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

+ (BOOL)_decompileSingleModelFile:(NSString *)momPath inDirectory:(NSString *)xcdatamodelPath error:(NSError **)error
{
    NSData *modelXMLData = nil;
    BOOL success = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:momPath]) {
        NSManagedObjectModel *model = nil;
        @try {
            // The best way to find out if the file contains a valid model is to try and load it.
            // Sadly, non-model data causes exceptions rather than returning error status.
            model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momPath]];
        }
        @catch (NSException *exception) {
            if (error != nil) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't open model file: %@", momPath]}];
                success = NO;
            }
        }
        
        if (model != nil) {
            NSXMLDocument *modelDocument = [model xmlDocument];
            modelXMLData = [modelDocument XMLDataWithOptions:NSXMLNodePrettyPrint|NSXMLNodeCompactEmptyElement|NSXMLDocumentIncludeContentTypeDeclaration];
        }
    }
    
    if (modelXMLData != nil) {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodelPath withIntermediateDirectories:YES attributes:0 error:error];
        if (success) {
            NSString *modelXMLPath = [xcdatamodelPath stringByAppendingPathComponent:@"contents"];
            success = [modelXMLData writeToFile:modelXMLPath atomically:YES];
        }
    }
    return success;
}

+ (BOOL)_decompileModelBundleAtPath:(NSString *)momdPath inDirectory:(NSString *)xcdatamodeldPath error:(NSError **)error
{
    BOOL isDirectory;
    BOOL success = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:momdPath isDirectory:&isDirectory] && isDirectory) {
        // Create a new xcdatamodeld container
        success = [[NSFileManager defaultManager] createDirectoryAtPath:xcdatamodeldPath withIntermediateDirectories:YES attributes:0 error:error];
        
        if (success) {
            NSArray *momdContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:momdPath error:error];
            if ([momdContents count] > 0) {
                for (NSString *filename in momdContents) {
                    NSString *fullPath = [momdPath stringByAppendingPathComponent:filename];
                    if ([filename hasSuffix:@".mom"]) {
                        // Process each model in the momd. Name the .xcdatamodel based on the .mom filename.
                        NSString *xcdatamodelPath = [xcdatamodeldPath stringByAppendingPathComponent:[[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"]];
                        success = [NSManagedObjectModel _decompileSingleModelFile:fullPath inDirectory:xcdatamodelPath error:error];
                        if (!success) {
                            break;
                        }
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
        }
    }
    return success;
}

+ (NSString *)_decompileAppBundleAtPath:(NSString *)appBundlePath inDirectory:(NSString *)resultDirectoryPath error:(NSError **)error
{
    BOOL isDirectory;
    NSString *xcModelPath = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:appBundlePath isDirectory:&isDirectory] && isDirectory) {
        // Find the first mom or momd in the app bundle, decompile it and return.
        NSDirectoryEnumerator *appBundleEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:appBundlePath];
        NSString *currentPath;
        while (((currentPath = [appBundleEnumerator nextObject])) && (xcModelPath == nil)) {
            if ([currentPath hasSuffix:@".mom"]) {
                NSString *fullMomPath = [appBundlePath stringByAppendingPathComponent:currentPath];
                NSString *xcdatamodelPath = [resultDirectoryPath stringByAppendingPathComponent:[[[appBundlePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"]];
                if([NSManagedObjectModel _decompileSingleModelFile:fullMomPath inDirectory:xcdatamodelPath error:error]) {
                    xcModelPath = xcdatamodelPath;
                }
            } else if ([currentPath hasSuffix:@".momd"]) {
                NSString *fullMomdPath = [appBundlePath stringByAppendingPathComponent:currentPath];
                NSString *xcdatamodeldPath = [resultDirectoryPath stringByAppendingPathComponent:[[[appBundlePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodeld"]];
                if ([NSManagedObjectModel _decompileModelBundleAtPath:fullMomdPath inDirectory:xcdatamodeldPath error:error]) {
                    xcModelPath = xcdatamodeldPath;
                }
            }
        }
    }
    if (xcModelPath == nil) {
        if (error != nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not find a compiled model at %@", appBundlePath]}];
        }
    }
    return xcModelPath;
}

+ (NSString *)_decompileModelFromBaseline:(NSString *)baselinePath inDirectory:(NSString *)resultDirectoryPath error:(NSError **)error
{
    BOOL isDirectory;
    BOOL success = YES;
    NSString *xcModelPath = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:baselinePath isDirectory:&isDirectory] && (!isDirectory)) {
        // Unpack baseline.zip into a temporary directory
        NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"momdec-%d", getpid()]];
        success = [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:error];
        if (!success) {
            return nil;
        }
        NSTask *unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"];
        [unzipTask setArguments:@[baselinePath, @"-d", tempDir]];
        NSPipe *taskStderr = [NSPipe pipe];
        [unzipTask setStandardError:taskStderr];
        [unzipTask launch];
        [unzipTask waitUntilExit];
        
        if ([unzipTask terminationStatus] != 0) {
            success = NO;
            if (error != nil) {
                NSFileHandle *taskStderrFileHandle = [taskStderr fileHandleForReading];
                NSData *taskStderrData = [taskStderrFileHandle readDataToEndOfFile];
                NSString *taskStdErrString = [[NSString alloc] initWithData:taskStderrData encoding:NSUTF8StringEncoding];
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: taskStdErrString}];
            }
        }
        
        if (success) {
            // Get the model name
            NSString *xcdatamodelPath = nil;
            NSString *storeFilenamePath = [tempDir stringByAppendingPathComponent:@"storeFilename"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:storeFilenamePath]) {
                // storeFileName contains a string formated as "Foo.sqlite". Set the model name based on that.
                NSString *storeFilename = [NSString stringWithContentsOfFile:storeFilenamePath encoding:NSUTF8StringEncoding error:error];
                if ([storeFilename length] != 0) {
                    NSString *xcdatamodelFileName = [[storeFilename stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"];
                    xcdatamodelPath = [resultDirectoryPath stringByAppendingPathComponent:xcdatamodelFileName];
                }
            } else {
                if (error != nil) {
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Incomplete baseline.zip contents"}];
                }
            }
            
            // Get the model itself
            NSString *momPath = [tempDir stringByAppendingPathComponent:@"gcmodel"];
            
            if ((xcdatamodelPath != nil) && (momPath != nil)) {
                success = [NSManagedObjectModel _decompileSingleModelFile:momPath inDirectory:xcdatamodelPath error:error];
                if (success) {
                    xcModelPath = xcdatamodelPath;
                }
            }
        }
    }
    return xcModelPath;
}

+ (NSString *)decompileModelAtPath:(NSString *)modelPath inDirectory:(NSString *)resultDirectoryPath error:(NSError **)error
{
    modelPath = [modelPath stringByStandardizingPath];
    NSString *decompiledPath = nil;
    if ([modelPath hasSuffix:@".mom"]) {
        NSString *xcdatamodelPath = [resultDirectoryPath stringByAppendingPathComponent:[[[modelPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodel"]];
        if ([NSManagedObjectModel _decompileSingleModelFile:modelPath inDirectory:xcdatamodelPath error:error]) {
            decompiledPath = xcdatamodelPath;
        }
    } else if ([modelPath hasSuffix:@".momd"]) {
        NSString *xcdatamodeldPath = [resultDirectoryPath stringByAppendingPathComponent:[[[modelPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"xcdatamodeld"]];
        if ([NSManagedObjectModel _decompileModelBundleAtPath:modelPath inDirectory:xcdatamodeldPath error:error]) {
            decompiledPath = xcdatamodeldPath;
        }
    } else if ([modelPath hasSuffix:@".app"]) {
        decompiledPath = [NSManagedObjectModel _decompileAppBundleAtPath:modelPath inDirectory:resultDirectoryPath error:error];
    } else if ([[modelPath lastPathComponent] isEqualToString:@"baseline.zip"]) {
        // Get the model from an iCloud baseline file
        decompiledPath = [NSManagedObjectModel _decompileModelFromBaseline:modelPath inDirectory:resultDirectoryPath error:error];
    } else {
        if (error != nil) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unrecognized file: %@", modelPath]}];
        }
    }
    return decompiledPath;
}
@end
