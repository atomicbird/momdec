# momdec: Core Data Model Decompiler

**momdec** is a command-line tool for Mac OS X that takes a compiled Core Data model and decompiles it to produce an equivalent `xcdatamodel` or `xcdatamodeld` suitable for use in Xcode. The resulting model file can also be used with [mogenerator](https://github.com/rentzsch/mogenerator) to produce source code files for Core Data entities which have custom subclasses.

# Usage

    momdec (Foo.mom|Foo.momd) [output directory]

The first argument is the full path to a .mom or .momd, and the second is the location where the results should be written. If the second argument is omitted, the current working directory is used. Output files are automatically named based on the inputs.

If the first argument is a `.mom`, that is, a single managed object model, `momdec` produces a `.xcdatamodel`. If the first argument is a `.momd` (which potentially contains multiple managed object models), `momdec` produces a `.xcdatamodeld` containing all models found, as well as a `.xccurrentversion` file (if appropriate) indicating the current version

## Command line

    momdec Foo.mom /private/tmp/

Creates `Foo.xcdatamodel` in /private/tmp/

    momdec Foo.momd

Creates `Foo.xcdatamodeld` in the current working directory. This bundle will include all model versions present in the `momd` and (if appropriate) a `.xccurrentversion` file.

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

# Limitations

Min/max values on numeric attributes are currently not supported.

# Credits

By Tom Harrington, @atomicbird on most social networks.
