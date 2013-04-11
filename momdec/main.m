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

/*
 Source Result
 *.mom  *.xcdatamodel
 *.momd *.xcdatamodeld
 */

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        NSArray *args = [[NSProcessInfo processInfo] arguments];
        
        if ([args count] > 1) {
            NSString *filename = [args objectAtIndex:1];
            [NSManagedObjectModel decompileModelAtPath:filename inDirectory:@"."];
            return 0;
        } else {
            fprintf(stderr, "Usage: momdec [foo.mom|foo.momd]");
        }
    }
    return 0;
}

