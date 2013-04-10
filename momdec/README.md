# momdec: Core Data Model Decompiler

**momdec** is a command-line tool for Mac OS X that takes a compiled Core Data model and decompiles it to produce an equivalent `xcdatamodel` or `xcdatamodeld` suitable for use in Xcode.

# Usage

## Command line

    momdec Foo.mom

Creates `Foo.xcdatamodel` in the current directory.

    momdec Foo.momd

Creates `Foo.xcdatamodeld` in the current working directory. This bundle will include all models present in the `momd`. It also includes a `.xccurrentversion` file so that Xcode will know which model is the current version.

## Source code

This project includes a number of categories on Core Data classes which could be used in other projects. The main entry point would be in `NSManagedObjectModel+xmlElement.h`, which includes the following methods:

    - (NSXMLElement *)xmlElement;

Returns an `NSXMLElement` representing the model

    - (NSXMLDocument *)xmlDocument;

Returns a full `NSXMLDocument` representing the model. This just calls `xmlElement`, sets that element as the document root, and adds document-level metadata.

    + (NSString *)decompileModelAtPath:(NSString *)momPath;

Decompiles the `mom` or `momd` at the specified path and returns the file name of the decompiled model.

Other categories consist of just an `xmlElement` method, which returns an `NSXMLElement` representing the receiver's portion of the decompiled model document.

# Requirements

Developed with Mac OS X 10.8.3 and Xcode 4.6.1. May work with older versions of both, but this has not been tested.

# License

MIT-style license, see LICENSE for details.

# Credits

By Tom Harrington, @atomicbird on most social networks.

# To do

* Fetch requests
* Min/max attribute values-- which are part of the validationPredicates
* Make sure model configurations work
