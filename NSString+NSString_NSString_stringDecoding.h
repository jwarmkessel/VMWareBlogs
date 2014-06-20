//
//  NSString+NSString_NSString_stringDecoding.h
//  VMwareBlogs
//
//  Created by Justin Warmkessel on 6/20/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_NSString_stringDecoding)

+ (NSString *)stringByStrippingTags:(NSString *)stringtoParse;
+ (NSString *)stringByRemovingNewLinesAndWhitespace:(NSString*)stringToParse;
+ (NSString *)stringByDecodingXMLEntities: (NSString *)stringToParse;
@end
