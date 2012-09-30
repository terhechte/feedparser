//
//  FPXMLParser_Private.h
//  NSBrief
//
//  Created by Saul Mora on 9/29/12.
//  Copyright (c) 2012 Magical Panda Software. All rights reserved.
//

#import "FPXMLParser.h"

@interface FPXMLParser ()
{
    //	NSMutableArray *extensionElements;
	id<FPXMLParserProtocol> parentParser; // non-retained

    //	NSDictionary *handlers;
	NSMutableString *currentTextValue;
	NSDictionary *currentAttributeDict;
	FPXMLParserElementType currentElementType;
	NSUInteger skipDepth;

	SEL currentHandlerSelector;
}

@property (nonatomic, assign, readwrite) NSUInteger parseDepth;
@property (nonatomic, copy, readwrite) NSString *baseNamespaceURI;
@property (nonatomic, copy, readwrite) NSMutableArray *extensionElementNodes;
@property (nonatomic, copy, readwrite) NSDictionary *handlers;

@end
