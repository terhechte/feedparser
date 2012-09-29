//
//  FPLink.m
//  FeedParser
//
//  Created by Kevin Ballard on 4/10/09.
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

#import "FPLink.h"
#import "NSString_extensions.h"

@implementation FPLink

+ (id)linkWithHref:(NSString *)href rel:(NSString *)rel type:(NSString *)type title:(NSString *)title
{
	return [[self alloc] initWithHref:href rel:rel type:type title:title];
}

- (id)initWithHref:(NSString *)inHref rel:(NSString *)inRel type:(NSString *)inType title:(NSString *)inTitle
{
	if ((self = [super init])) {
		_href = [inHref copy];
		_rel = (inRel ? [inRel copy] : @"alternate");
		_type = [inType copy];
		_title = [inTitle copy];
	}
	return self;
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[FPLink class]]) return NO;

	FPLink *other = (FPLink *)anObject;
	return ((_href  == other->_href  || [_href  isEqualToString:other->_href]) &&
			(_rel   == other->_rel   || [_rel   isEqualToString:other->_rel])  &&
			(_type  == other->_type  || [_type  isEqualToString:other->_type]) &&
			(_title == other->_title || [_title isEqualToString:other->_title]));
}

- (NSString *)description
{
	NSMutableArray *attributes = [NSMutableArray array];

	for (NSString *key in [NSArray arrayWithObjects:@"rel", @"type", @"title", nil])
    {
		NSString *value = [self valueForKey:key];
		if (value != nil)
        {
			[attributes addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, [value fpEscapedString]]];
		}
	}
	return [NSString stringWithFormat:@"<%@: %@ (%@)>", NSStringFromClass([self class]), self.href, [attributes componentsJoinedByString:@" "]];
}

#pragma mark -
#pragma mark Coding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init]))
    {
		_href = [[aDecoder decodeObjectForKey:@"href"] copy];
		_rel = [[aDecoder decodeObjectForKey:@"rel"] copy];
		_type = [[aDecoder decodeObjectForKey:@"type"] copy];
		_title = [[aDecoder decodeObjectForKey:@"title"] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_href forKey:@"href"];
	[aCoder encodeObject:_rel forKey:@"rel"];
	[aCoder encodeObject:_type forKey:@"type"];
	[aCoder encodeObject:_title forKey:@"title"];
}

@end
