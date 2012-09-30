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
#import "FPXMLParser+Private.h"

@interface FPFeed ()

@property (nonatomic, copy, readwrite) NSString     *title;
@property (nonatomic, strong, readwrite) FPLink       *link;
@property (nonatomic, copy, readwrite) NSString     *feedDescription;
@property (nonatomic, copy, readwrite) NSDate       *pubDate;

@property (nonatomic, copy, readwrite) NSString     *itunesAuthor;
@property (nonatomic, copy, readwrite) NSString     *itunesImageURLString;
@property (nonatomic, copy, readwrite) NSString     *itunesKeywords;
@property (nonatomic, copy, readwrite) NSArray      *itunesCategories;
@property (nonatomic, copy, readwrite) NSNumber     *itunesIsExplicit;
@property (nonatomic, copy, readwrite) NSString     *itunesOwnerName;
@property (nonatomic, copy, readwrite) NSString     *itunesOwnerEmail;

@property (nonatomic, strong, readwrite) NSMutableArray *feedLinks;
@property (nonatomic, strong, readwrite) NSMutableArray *feedItems;

@end


@implementation FPFeed

@synthesize link = _link;

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

- (id) initWithBaseNamespaceURI:(NSString *)namespaceURI
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

- (NSArray *)links;
{
    return [NSArray arrayWithArray:self.feedLinks];
}

- (NSArray *)items;
{
    return [NSArray arrayWithArray:self.feedItems];
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
	FPItem *item = [self newItemWithBaseNamespaceURI:self.baseNamespaceURI];
	[item acceptParsing:parser];
	[self.feedItems addObject:item];
}

- (void)rss_link:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	FPLink *aLink = [[FPLink alloc] initWithHref:textValue rel:@"alternate" type:nil title:nil];
	if (self.link == nil)
    {
		self.link = aLink;
	}
	[self.feedLinks addObject:aLink];
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

	if (self.link == nil && [aLink.rel isEqualToString:@"alternate"])
    {
		self.link = aLink;
	}
	[self.feedLinks addObject:aLink];
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
    BOOL isEqual = YES;
    isEqual &= (self.title           == other.title           || [self.title           isEqualToString:other.title]);
    isEqual &= (self.link            == other.link            || [self.link            isEqual:other.link]);
    isEqual &= (self.feedLinks       == other.feedLinks       || [self.feedLinks       isEqualToArray:other.feedLinks]);
    isEqual &= (self.feedDescription == other.feedDescription || [self.feedDescription isEqualToString:other.feedDescription]);
    isEqual &= (self.pubDate         == other.pubDate         || [self.pubDate         isEqual:other.pubDate]);
    isEqual &= (self.feedItems       == other.feedItems       || [self.feedItems       isEqualToArray:other.feedItems]);

    return isEqual;
}

#pragma mark -
#pragma mark Coding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
    {
		self.title = [aDecoder decodeObjectForKey:@"title"];
		self.link = [aDecoder decodeObjectForKey:@"link"];
		self.feedDescription = [aDecoder decodeObjectForKey:@"description"];
		self.pubDate = [aDecoder decodeObjectForKey:@"pubDate"];
		self.feedLinks = [[aDecoder decodeObjectForKey:@"links"] mutableCopy];
		self.feedItems = [[aDecoder decodeObjectForKey:@"items"] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.link forKey:@"link"];
	[aCoder encodeObject:self.feedLinks forKey:@"links"];
	[aCoder encodeObject:self.feedDescription forKey:@"description"];
	[aCoder encodeObject:self.pubDate forKey:@"pubDate"];
	[aCoder encodeObject:self.feedItems forKey:@"items"];
}

@end
