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

- (void)_removeElementsNodeFromDocument:(NSXMLDocument *)modelDocument
{
    int elementsIndex = -1;
    for (elementsIndex=0; elementsIndex<[[modelDocument rootElement] childCount]; elementsIndex++) {
        // The "elements" node contains graphical editor positioning info, which is not included in the compiled model.
        // Since these can't possibly match, they're removed before comparing.
        NSXMLNode *currentChild = [[modelDocument rootElement] childAtIndex:elementsIndex];
        if ([[currentChild name] isEqualToString:@"elements"]) {
            break;
        }
    }
    if (elementsIndex >= 0) {
        [[modelDocument rootElement] removeChildAtIndex:elementsIndex];
    }
}

- (void)testDecompile
{
    NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];

    // Get the original uncompiled model
    NSURL *uncompiledModelURL = [[selfBundle resourceURL] URLByAppendingPathComponent:@"momdecTests.xcdatamodeld/momdecTests.xcdatamodel/contents"];
    NSXMLDocument *uncompiledModelDocument = [[NSXMLDocument alloc] initWithContentsOfURL:uncompiledModelURL options:0 error:nil];
    // Clean up some hopefully-irrelevant details not included in the compiled model.
    [self _removeElementsNodeFromDocument:uncompiledModelDocument];
    [[uncompiledModelDocument rootElement] removeAttributeForName:@"lastSavedToolsVersion"];
    [[uncompiledModelDocument rootElement] removeAttributeForName:@"systemVersion"];
    
    // Get the compiled model and decompile it.
    NSURL *momURL = [selfBundle URLForResource:@"momdecTests" withExtension:@"momd"];
    NSManagedObjectModel *compiledModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    NSXMLDocument *decompiledModelDocument = [compiledModel xmlDocument];
    [self _removeElementsNodeFromDocument:decompiledModelDocument];
    
    // Compare the two non-compiled versions
    NSLog(@"uncompiled: %@", uncompiledModelDocument);
    NSLog(@"decompiled: %@", decompiledModelDocument);
    
    if (![decompiledModelDocument isEqual:uncompiledModelDocument]) {
        STFail(@"Decompiled document does not match");
    }
}

@end
