//
//  FPFeed.h
//  FeedParser
//
//  Created by Kevin Ballard on 4/4/09.
//  Copyright 2009 Kevin Ballard. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <Foundation/Foundation.h>
#import "FPXMLParser.h"

@class FPParser;
@class FPLink;
@class FPItem;

@interface FPFeed : FPXMLParser <NSCoding> 

@property (nonatomic, copy, readonly) NSString *title;
// RSS <link> or Atom <link rel="alternate">
// If multiple qualifying links exist, the first is returned
@property (nonatomic, strong, readonly) FPLink *link;

// An array of FPLink objects corresponding to Atom <link> elements
// RSS <link> elements are represented as links of rel="alternate"
@property (nonatomic, copy, readonly) NSArray *links;
@property (nonatomic, copy, readonly) NSString *feedDescription;
@property (nonatomic, copy, readonly) NSDate *pubDate;
@property (nonatomic, retain, readonly) NSArray *items;

@property (nonatomic, copy, readonly) NSString *itunesSubtitle;
@property (nonatomic, copy, readonly) NSString *itunesSummary;
@property (nonatomic, copy, readonly) NSString *itunesAuthor;
@property (nonatomic, copy, readonly) NSString *itunesImageURLString;
@property (nonatomic, copy, readonly) NSString *itunesKeywords;
@property (nonatomic, copy, readonly) NSArray *itunesCategories;
@property (nonatomic, copy, readonly) NSNumber *itunesIsExplicit;

@property (nonatomic, copy, readonly) NSString *itunesOwnerName;
@property (nonatomic, copy, readonly) NSString *itunesOwnerEmail;

// parent class defines property NSArray *extensionElements
// parent class defines method -(NSArray *)extensionElementsWithXMLNamespace:(NSString *)namespaceURI
// parent class defines method - (NSArray *)extensionElementsWithXMLNamespace:(NSString *)namespaceURI elementName:(NSString *)elementName
- (FPItem *)newItemWithBaseNamespaceURI:(NSString *)namespaceURI;

@end
