//
//  main.m
//  momdec
//
//  Created by Tom Harrington on 4/6/13.
//  Copyright (c) 2013 Tom Harrington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectModel+xmlElement.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        NSArray *args = [[NSProcessInfo processInfo] arguments];
        
        for (int i=1; i<[args count]; i++) {
            NSString *argument = [args objectAtIndex:i];
            NSLog(@"arg: %@", argument);
            
            NSURL *fileUrl = [NSURL fileURLWithPath:argument];
            NSLog(@"URL: %@", [fileUrl absoluteString]);
            
            NSManagedObjectModel *model = nil;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
                @try {
                    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:fileUrl];
                    NSLog(@"Opened %@", argument);
                }
                @catch (NSException *exception) {
                    NSLog(@"%@ is not a compiled managed object model", argument);
                }
                @finally {
                    
                }
                NSXMLElement *modelElement = [model xmlElement];
                NSLog(@"model XML element: %@", modelElement);
                
                NSXMLDocument *modelDocument = [model xmlDocument];
                NSLog(@"Model XML document: %@", modelDocument);
                NSData *modelXMLData = [modelDocument XMLDataWithOptions:NSXMLNodePrettyPrint|NSXMLDocumentIncludeContentTypeDeclaration];
                [modelXMLData writeToFile:@"/tmp/test.xml" atomically:YES];
            } else {
                NSLog(@"File not found: %@", argument);
            }
        }
        
    }
    return 0;
}

