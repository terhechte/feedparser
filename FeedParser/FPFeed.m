//
//  FPFeed.m
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

#import "FPFeed.h"
#import "FPItem.h"
#import "FPLink.h"
#import "FPParser.h"
#import "NSDate_FeedParserExtensions.h"
#import "FPExtensionElementNode.h"

@interface FPFeed ()
//{
//	NSMutableArray *links;
//	NSMutableArray *items;
//}

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *feedDescription;
@property (nonatomic, copy, readwrite) NSDate *pubDate;

@property (nonatomic, copy, readwrite) NSString *itunesAuthor;
@property (nonatomic, copy, readwrite) NSString *itunesImageURLString;
@property (nonatomic, copy, readwrite) NSString *itunesKeywords;
@property (nonatomic, copy, readwrite) NSArray *itunesCategories;
@property (nonatomic, copy, readwrite) NSNumber *itunesIsExplicit;
@property (nonatomic, copy, readwrite) NSString *itunesOwnerName;
@property (nonatomic, copy, readwrite) NSString *itunesOwnerEmail;

@property (nonatomic, strong, readwrite) NSMutableArray *feedLinks;
@property (nonatomic, strong, readwrite) NSMutableArray *feedItems;

//- (void)rss_pubDate:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
//- (void)rss_item:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
//- (void)rss_link:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
//- (void)atom_link:(NSDictionary *)attributes parser:(NSXMLParser *)parser;

@end

@implementation FPFeed

//@synthesize title, link, links, feedDescription, pubDate, items;
//@synthesize itunesAuthor;
//@synthesize itunesImageURLString;
//@synthesize itunesKeywords;
//@synthesize itunesCategories;
//@synthesize itunesIsExplicit;
//@synthesize itunesOwnerName;
//@synthesize itunesOwnerEmail;

+ (void)initialize
{
	if (self == [FPFeed class])
    {
		[self registerRSSHandler:@selector(setTitle:) forElement:@"title" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(rss_link:attributes:parser:) forElement:@"link" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(setFeedDescription:) forElement:@"description" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(rss_pubDate:attributes:parser:) forElement:@"pubDate" type:FPXMLParserTextElementType];
        
        [self registerTextHandler:@selector(setItunesAuthor:) forElement:@"author" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
        [self registerTextHandler:@selector(itunes_image:attributes:parser:) forElement:@"image" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
        [self registerTextHandler:@selector(setItunesKeywords:) forElement:@"keywords" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
        [self registerHandler:@selector(itunes_category:parser:) forElement:@"category" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI type:FPXMLParserExtensionElementType];
        [self registerTextHandler:@selector(itunes_explicit:attributes:parser:) forElement:@"explicit" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
        
        [self registerHandler:@selector(itunes_owner:parser:) forElement:@"owner" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI type:FPXMLParserExtensionElementType];
        [self registerTextHandler:@selector(itunes_ownername:attributes:parser:) forElement:@"name" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];

        [self registerTextHandler:@selector(setItunesOwnerEmail:) forElement:@"email" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
        
		for (NSString *key in [NSArray arrayWithObjects:
							   @"language", @"copyright", @"managingEditor", @"webMaster", @"lastBuildDate", @"category",
							   @"generator", @"docs", @"cloud", @"ttl", @"image", @"rating", @"textInput", @"skipHours", @"skipDays", nil]) {
			[self registerRSSHandler:NULL forElement:key type:FPXMLParserSkipElementType];
		}
		[self registerRSSHandler:@selector(rss_item:parser:) forElement:@"item" type:FPXMLParserStreamElementType];
		
		// atom elements
		[self registerAtomHandler:@selector(atom_link:parser:) forElement:@"link" type:FPXMLParserSkipElementType];
	}
}

- (id)initWithBaseNamespaceURI:(NSString *)namespaceURI
{
	if ((self = [super initWithBaseNamespaceURI:namespaceURI]))
    {
		_feedItems = [[NSMutableArray alloc] init];
		_feedLinks = [[NSMutableArray alloc] init];
	}
	return self;
}

- (FPItem *)newItemWithBaseNamespaceURI:(NSString *)namespaceURI
{
	return [[FPItem alloc] initWithBaseNamespaceURI: namespaceURI];
}

- (void)rss_pubDate:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	NSDate *date = [NSDate dateWithRFC822:textValue];
	self.pubDate = date;
	if (date == nil)
    {
        [self abortParsing:parser withFormat:@"could not parse pubDate '%@'", textValue];
    }
}

- (void)rss_item:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	FPItem *item = [self newItemWithBaseNamespaceURI:baseNamespaceURI];
	[item acceptParsing:parser];
	[_feedItems addObject:item];
}

- (void)rss_link:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	FPLink *aLink = [[FPLink alloc] initWithHref:textValue rel:@"alternate" type:nil title:nil];
	if (_link == nil)
    {
		_link = aLink;
	}
	[_feedLinks addObject:aLink];
}

- (void) itunes_owner:(FPExtensionElementNode *)node parser:(NSXMLParser *)parser;
{
    for (FPExtensionNode *child in node.children)
    {
        if (child.isTextNode)
        {
            continue;
        }
        if ([child.name isEqualToString:@"name"]) 
        {
            self.itunesOwnerName = [child stringValue];
        }
        else
        {
            self.itunesOwnerEmail = [child stringValue];
        }
    }
}

- (void)atom_link:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	NSString *href = [attributes objectForKey:@"href"];
	if (href == nil) return; // sanity check
    
	FPLink *aLink = [[FPLink alloc] initWithHref:href
                                             rel:attributes[@"rel"]
                                            type:attributes[@"type"]
										   title:attributes[@"title"]];

	if (link == nil && [aLink.rel isEqualToString:@"alternate"])
    {
		_link = aLink;
	}
	[_feedLinks addObject:aLink];
}

- (void) itunes_image:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
{
    self.itunesImageURLString = [attributes valueForKey:@"href"];
}

- (void) itunes_explicit:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
{
    NSString *value = [textValue lowercaseString];
    if (value)
    {
        self.itunesIsExplicit = [NSNumber numberWithBool:[value isEqualToString:@"yes"]];
    }
}

- (void) itunes_category:(FPExtensionElementNode *)node parser:(NSXMLParser *)parser;
{
    if (self.itunesCategories == nil)
    {
        self.itunesCategories = [NSArray array];
    }
    self.itunesCategories = [self.itunesCategories arrayByAddingObject:[node.attributes valueForKey:@"text"]];
    for (FPExtensionElementNode *child in node.children) //flatten hierarchy for now
    {
        if (child.isElement) 
        {
            [self itunes_category:child parser:parser];
        }
    }
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[FPFeed class]]) return NO;

	FPFeed *other = (FPFeed *)anObject;
	return ((_title           == other->_title            || [_title           isEqualToString:other->_title])           &&
			(_link            == other->_link            || [_link            isEqual:other->_link])                    &&
			(_feedLinks       == other->_feedLinks       || [_feedLinks           isEqualToArray:other->_feedLinks])            &&
			(_feedDescription == other->_feedDescription || [_feedDescription isEqualToString:other->_feedDescription]) &&
			(_pubDate         == other->_pubDate         || [_pubDate         isEqual:other->_pubDate])                 &&
			(_items           == other->_items           || [_items           isEqualToArray:other->_items]));
}

#pragma mark -
#pragma mark Coding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
    {
		_title = [[aDecoder decodeObjectForKey:@"title"] copy];
		_link = [aDecoder decodeObjectForKey:@"link"];
		_feedLinks = [[aDecoder decodeObjectForKey:@"links"] mutableCopy];
		_feedDescription = [[aDecoder decodeObjectForKey:@"feedDescription"] copy];
		_pubDate = [[aDecoder decodeObjectForKey:@"pubDate"] copy];
		_items = [[aDecoder decodeObjectForKey:@"items"] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:_title forKey:@"title"];
	[aCoder encodeObject:_link forKey:@"link"];
	[aCoder encodeObject:_feedLinks forKey:@"links"];
	[aCoder encodeObject:_feedDescription forKey:@"feedDescription"];
	[aCoder encodeObject:_pubDate forKey:@"pubDate"];
	[aCoder encodeObject:_items forKey:@"items"];
}

@end
