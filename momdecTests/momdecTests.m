//
//  momdecTests.m
//  momdecTests
//
//  Created by Tom Harrington on 4/9/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import "momdecTests.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectModel+xmlElement.h"
#import "NSPropertyDescription+xmlElement.h"

@implementation momdecTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDecompile
{
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];

    // Get the compiled model
    NSURL *momURL = [selfBundle URLForResource:@"momdecTests" withExtension:@"momd"];
    NSManagedObjectModel *compiledModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    // Decompile the model into a temporary directory
    NSString *momdecTestDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"momdecTests-%d", getpid()]];
    [[NSFileManager defaultManager] createDirectoryAtPath:momdecTestDir withIntermediateDirectories:YES attributes:0 error:nil];
    NSError *error = nil;
    NSString *decompiledModelContainerPath = [NSManagedObjectModel decompileModelAtPath:[momURL path] inDirectory:momdecTestDir error:&error];
    XCTAssertNil(error, @"Error decompiling model: %@", error);
    XCTAssertTrue(([decompiledModelContainerPath length] > 0), @"Zero-length path after decompiling model");
    
    // Compile the temporary file copy
    NSString *recompiledModelPath = [momdecTestDir stringByAppendingPathComponent:@"momdecTests.momd"];
    NSTask *compileTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/xcrun" arguments:@[@"momc", decompiledModelContainerPath, recompiledModelPath]];
    [compileTask waitUntilExit];
    XCTAssertEqual([compileTask terminationStatus], 0, @"xcrun failed to compile the model, try running 'xcrun momc' in Terminal.app and trying again");
    
    // Load the recompiled model
    NSManagedObjectModel *recompiledModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recompiledModelPath]];
    
    // Compare the original compiled model with the recompiled version.
    NSDictionary *originalEntities = [compiledModel entitiesByName];
    NSDictionary *recompiledEntities = [recompiledModel entitiesByName];
    for (NSString *entityName in originalEntities) {
        NSEntityDescription *originalEntity = originalEntities[entityName];
        NSEntityDescription *recompiledEntity = recompiledEntities[entityName];
        XCTAssertEqualObjects(originalEntity, recompiledEntity, @"Entities do not match: %@", entityName);
    }

    NSDictionary *originalFetchRequests = [compiledModel fetchRequestTemplatesByName];
    NSDictionary *recompiledFetchRequests = [recompiledModel fetchRequestTemplatesByName];
    for (NSString *fetchRequestName in originalFetchRequests) {
        NSFetchRequest *originalFetchRequest = originalFetchRequests[fetchRequestName];
        NSFetchRequest *recompiledFetchRequest = recompiledFetchRequests[fetchRequestName];
        XCTAssertEqualObjects(originalFetchRequest, recompiledFetchRequest, @"Fetch requests do not match: %@", fetchRequestName);
    }
    
    NSArray *originalConfigurations = [compiledModel configurations];
    for (NSString *configurationName in originalConfigurations) {
        XCTAssertEqualObjects([compiledModel entitiesForConfiguration:configurationName], [recompiledModel entitiesForConfiguration:configurationName], @"Configuration does not match: %@", configurationName);
    }
}

- (void)testPropertyDescriptionException
{
    NSPropertyDescription *testProperty = [[NSPropertyDescription alloc] init];
    BOOL exceptionThrown = NO;
    @try {
        [testProperty xmlElement];
    }
    @catch (NSException *exception) {
        exceptionThrown = YES;
    }
    @finally {
        XCTAssertTrue(exceptionThrown, @"NSPropertyDescription should throw an exception if you ask for its xmlElement");
    }
}

@end
