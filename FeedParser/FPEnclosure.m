//
//  FPEnclosure.m
//  FeedParser
//
//  Created by Kevin Ballard on 11/20/09.
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

#import "FPEnclosure.h"


@implementation FPEnclosure

+ (id)enclosureWithURL:(NSString *)url length:(NSUInteger)length type:(NSString *)type
{
	return [[self alloc] initWithURL:url length:length type:type];
}

- (id)initWithURL:(NSString *)inurl length:(NSUInteger)inlength type:(NSString *)intype
{
	if ((self = [super init]))
    {
		_url = [inurl copy];
		_length = inlength;
		_type = [intype copy];
	}
	return self;
}

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[FPEnclosure class]]) return NO;
    
	FPEnclosure *other = (FPEnclosure *)object;
	return ((_url    == other->_url  || [_url  isEqualToString:other->_url]) &&
			(_type   == other->_type || [_type isEqualToString:other->_type]) &&
			(_length == other->_length));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %@ (length=%lu type=\"%@\")>", NSStringFromClass([self class]), self.url, (unsigned long)self.length, self.type];
}

#pragma mark -
#pragma mark Coding Support

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init]))
    {
		_url = [[aDecoder decodeObjectForKey:@"url"] copy];
		_length = [[aDecoder decodeObjectForKey:@"length"] unsignedIntegerValue];
		_type = [[aDecoder decodeObjectForKey:@"type"] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_url forKey:@"url"];
	[aCoder encodeObject:@(_length) forKey:@"length"];
	[aCoder encodeObject:_type forKey:@"type"];
}
@end
