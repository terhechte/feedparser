//
//  FPItem.m
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

#import "FPItem.h"
#import "FPLink.h"
#import "FPEnclosure.h"
#import "NSDate_FeedParserExtensions.h"

@interface FPItem ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *guid;
@property (nonatomic, copy, readwrite) NSString *itemDescription;
@property (nonatomic, copy, readwrite) NSString *content;
@property (nonatomic, copy, readwrite) NSString *creator;
@property (nonatomic, copy, readwrite) NSDate *pubDate;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, copy, readwrite) NSString *category;
@property (nonatomic, copy, readwrite) NSString *comments;
//For use with MediaRSS
@property (nonatomic, copy, readwrite) NSString *thumbnailURL;
// for use with itunes podcasts
@property (nonatomic, copy, readwrite) NSString *itunesAuthor;
@property (nonatomic, copy, readwrite) NSString *itunesSubtitle;
@property (nonatomic, copy, readwrite) NSString *itunesSummary;
@property (nonatomic, copy, readwrite) NSString *itunesBlock;
@property (nonatomic, copy, readwrite) NSString *itunesDuration;
@property (nonatomic, copy, readwrite) NSString *itunesKeywords;
@property (nonatomic, copy, readwrite) NSString *itunesExplict;

@property (nonatomic, strong, readwrite) NSMutableArray *itemLinks;
@property (nonatomic, strong, readwrite) NSMutableArray *itemEnclosures;

@end

@implementation FPItem

+ (void)initialize
{
	if (self == [FPItem class])
    {
		[self registerRSSHandler:@selector(setTitle:) forElement:@"title" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(setAuthor:) forElement:@"author" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(rss_link:attributes:parser:) forElement:@"link" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(setGuid:) forElement:@"guid" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(setItemDescription:) forElement:@"description" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(rss_pubDate:attributes:parser:) forElement:@"pubDate" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(setCategory:) forElement:@"category" type:FPXMLParserTextElementType];
		[self registerRSSHandler:@selector(rss_enclosure:parser:) forElement:@"enclosure" type:FPXMLParserSkipElementType];
        [self registerRSSHandler:@selector(comments:attributes:parser:) forElement:@"comments" type:FPXMLParserTextElementType];
		
		for (NSString *key in [NSArray arrayWithObjects:@"source", nil])
        {
			[self registerRSSHandler:NULL forElement:key type:FPXMLParserSkipElementType];
		}
		// Atom
		[self registerAtomHandler:@selector(atom_link:parser:) forElement:@"link" type:FPXMLParserSkipElementType];
		// DublinCore
		[self registerTextHandler:@selector(setCreator:) forElement:@"creator" namespaceURI:kFPXMLParserDublinCoreNamespaceURI];
		// Content
		[self registerTextHandler:@selector(setContent:) forElement:@"encoded" namespaceURI:kFPXMLParserContentNamespaceURI];
		// Media RSS
		[self registerHandler:@selector(mediaRSS_attributes:parser:) forElement:@"content" namespaceURI:kFPXMLParserMediaRSSNamespaceURI type:FPXMLParserStreamElementType];
		[self registerTextHandler:@selector(mediaRSS_thumbnail:attributes:parser:) forElement:@"thumbnail" namespaceURI:kFPXMLParserMediaRSSNamespaceURI];
		
		// Podcasts
		[self registerTextHandler:@selector(setItunesAuthor:) forElement:@"author" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesSubtitle:) forElement:@"subtitle" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesSummary:) forElement:@"summary" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesBlock:) forElement:@"block" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesDuration:) forElement:@"duration" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesKeywords:) forElement:@"keywords" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		[self registerTextHandler:@selector(setItunesExplict:) forElement:@"explict" namespaceURI:kFPXMLParserItunesPodcastNamespaceURI];
		 
	}
}

- (id)initWithBaseNamespaceURI:(NSString *)namespaceURI
{
	if ((self = [super initWithBaseNamespaceURI:namespaceURI]))
    {
		_itemLinks = [[NSMutableArray alloc] init];
		_itemEnclosures = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSArray *)links;
{
    return [NSArray arrayWithArray:self.itemLinks];
}

- (NSArray *)enclosures;
{
    return [NSArray arrayWithArray:self.itemEnclosures];
}

- (void)rss_pubDate:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	self.pubDate = [NSDate dateWithRFC822:textValue];
}

- (void)rss_link:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	FPLink *aLink = [[FPLink alloc] initWithHref:textValue rel:@"alternate" type:nil title:nil];

	if (_link == nil)
    {
		_link = aLink;
	}
	[_itemLinks addObject:aLink];
}

- (void)atom_link:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	NSString *href = attributes[@"href"];
	if (href == nil) return; // sanity check

	FPLink *aLink = [[FPLink alloc] initWithHref:href rel:attributes[@"rel"] type:attributes[@"type"] title:attributes[@"title"]];
	if (_link == nil && [aLink.rel isEqualToString:@"alternate"])
    {
		_link = aLink;
	}
	[_itemLinks addObject:aLink];
}

- (void) mediaRSS_thumbnail:(NSString *)text attributes:(NSDictionary*)attributes parser:(NSXMLParser *)parser
{
	NSString *url = attributes[@"url"];
	if(!url) return;

	self.thumbnailURL = url;
}

- (void) mediaRSS_attributes:(NSDictionary*)attributes parser:(NSXMLParser *)parser
{
	NSString *type = attributes[@"type"];
	NSString *url = attributes[@"url"];

	if(type && url)
    {
		if([type isEqualToString:@"image/jpeg"] || [type isEqualToString:@"image/png"])
        {
            self.thumbnailURL = url;
        }
	}
}

- (void) comments:(NSString *)textValue attributes:(NSDictionary *)attributes parser:(NSXMLParser *)parser;
{
    self.comments = textValue;
}

- (void)rss_enclosure:(NSDictionary *)attributes parser:(NSXMLParser *)parser
{
	NSString *url = attributes[@"url"];
	NSString *type = attributes[@"type"];
	NSString *lengthStr = attributes[@"length"];
	if (url == nil) return; // at minimum, url is required

	NSUInteger length = [lengthStr integerValue];
	FPEnclosure *anEnclosure = [[FPEnclosure alloc] initWithURL:url length:length type:type];
	[_itemEnclosures addObject:anEnclosure];
}

- (NSString *)content
{
	return (_content ?: _itemDescription);
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[FPItem class]]) return NO;
    
	FPItem *other = (FPItem *)anObject;
    BOOL isEqual = YES;
    isEqual &= (_title          == other->_title              || [_title       isEqualToString:other->_title]);
    isEqual &= (_link           == other->_link               || [_link        isEqual:other->_link]);
    isEqual &= (_itemLinks      == other->_itemLinks          || [_itemLinks   isEqualToArray:other->_itemLinks]);
    isEqual &= (_guid           == other->_guid               || [_guid        isEqualToString:other->_guid]);
    isEqual &= (_itemDescription == other->_itemDescription   || [_itemDescription isEqualToString:other->_itemDescription]);
    isEqual &= (_content        == other->_content            || [_content     isEqualToString:other->_content]);
    isEqual &= (_pubDate        == other->_pubDate            || [_pubDate     isEqual:other->_pubDate]);
    isEqual &= (_creator        == other->_creator            || [_creator     isEqualToString:other->_creator]);
    isEqual &= (_author         == other->_author             || [_author      isEqualToString:other->_author]);
    isEqual &= (_category       == other->_category           || [_category    isEqualToString:other->_category]);
    isEqual &= (_thumbnailURL   == other->_thumbnailURL   || [_thumbnailURL   isEqualToString:other->_thumbnailURL]);
    isEqual &= (_itunesAuthor   == other->_itunesAuthor   || [_itunesAuthor   isEqualToString:other->_itunesAuthor]);
    isEqual &= (_itunesSubtitle == other->_itunesSubtitle || [_itunesSubtitle isEqualToString:other->_itunesSubtitle]);
    isEqual &= (_itunesSummary  == other->_itunesSummary  || [_itunesSummary  isEqualToString:other->_itunesSummary]);
    isEqual &= (_itunesBlock    == other->_itunesBlock    || [_itunesBlock    isEqualToString:other->_itunesBlock]);
    isEqual &= (_itunesDuration == other->_itunesDuration || [_itunesDuration isEqualToString:other->_itunesDuration]);
    isEqual &= (_itunesKeywords == other->_itunesKeywords || [_itunesKeywords isEqualToString:other->_itunesKeywords]);
    isEqual &= (_itunesExplict  == other->_itunesExplict  || [_itunesExplict  isEqualToString:other->_itunesExplict]);
    isEqual &= (_itemEnclosures  == other->_itemEnclosures || [_itemEnclosures  isEqualToArray:other->_itemEnclosures]);

    return isEqual;
}

#pragma mark -
#pragma mark Coding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
    {
		_title = [[aDecoder decodeObjectForKey:@"title"] copy];
		_link = [aDecoder decodeObjectForKey:@"link"];
		_itemLinks = [[aDecoder decodeObjectForKey:@"links"] mutableCopy];
		_guid = [[aDecoder decodeObjectForKey:@"guid"] copy];
		_itemDescription = [[aDecoder decodeObjectForKey:@"description"] copy];
		_content = [[aDecoder decodeObjectForKey:@"content"] copy];
		_pubDate = [[aDecoder decodeObjectForKey:@"pubDate"] copy];
		_creator = [[aDecoder decodeObjectForKey:@"creator"] copy];
		_author = [[aDecoder decodeObjectForKey:@"author"] copy];
		_category = [[aDecoder decodeObjectForKey:@"category"] copy];
		_itemEnclosures = [[aDecoder decodeObjectForKey:@"enclosures"] mutableCopy];
		_thumbnailURL = [[aDecoder decodeObjectForKey:@"thumbnailURL"] copy];
		_itunesAuthor = [[aDecoder decodeObjectForKey:@"itunesAuthor"] copy];
		_itunesSubtitle = [[aDecoder decodeObjectForKey:@"itunesSubtitle"] copy];
		_itunesSummary = [[aDecoder decodeObjectForKey:@"itunesSummary"] copy];
		_itunesBlock = [[aDecoder decodeObjectForKey:@"itunesBlock"] copy];
		_itunesDuration = [[aDecoder decodeObjectForKey:@"itunesDuration"] copy];
		_itunesKeywords = [[aDecoder decodeObjectForKey:@"itunesKeywords"] copy];
		_itunesExplict = [[aDecoder decodeObjectForKey:@"itunesExplict"] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:_title forKey:@"title"];
	[aCoder encodeObject:_link forKey:@"link"];
	[aCoder encodeObject:_itemLinks forKey:@"links"];
	[aCoder encodeObject:_guid forKey:@"guid"];
	[aCoder encodeObject:_itemDescription forKey:@"description"];
	[aCoder encodeObject:_content forKey:@"content"];
	[aCoder encodeObject:_pubDate forKey:@"pubDate"];
	[aCoder encodeObject:_creator forKey:@"creator"];
	[aCoder encodeObject:_author forKey:@"author"];
	[aCoder encodeObject:_category forKey:@"category"];
	[aCoder encodeObject:_itemEnclosures forKey:@"enclosures"];
	[aCoder encodeObject:_thumbnailURL forKey:@"thumbnailURL"];
	[aCoder encodeObject:_itunesAuthor forKey:@"itunesAuthor"];
	[aCoder encodeObject:_itunesSubtitle forKey:@"itunesSubtitle"];
	[aCoder encodeObject:_itunesSummary forKey:@"itunesSummary"];
	[aCoder encodeObject:_itunesBlock forKey:@"itunesBlock"];
	[aCoder encodeObject:_itunesDuration forKey:@"itunesDuration"];
	[aCoder encodeObject:_itunesKeywords forKey:@"itunesKeywords"];
	[aCoder encodeObject:_itunesExplict forKey:@"itunesExplict"];
}

@end
