//
//  FPXMLPair.m
//  FeedParser
//
//  Created by Kevin Ballard on 4/6/09.
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

#import "FPXMLPair.h"

@implementation FPXMLPair


+ (id)pairWithFirst:(id)firstObject second:(id)secondObject
{
	return [[self alloc] initWithFirst:firstObject second:secondObject];
}

- (id)initWithFirst:(id)firstObject second:(id)secondObject
{
	if ((self = [super init])) {
		_first = firstObject;
		_second = secondObject;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[FPXMLPair allocWithZone:zone] initWithFirst:_first second:_second];
}

- (BOOL)isEqual:(id)anObject
{
	if ([anObject isKindOfClass:[FPXMLPair class]])
    {
		FPXMLPair *other = (FPXMLPair *)anObject;
		id oFirst = other.first;
		id oSecond = other.second;
		// do pointer test first so we handle nil properly
		return ((_first == oFirst || [_first isEqual:other.first]) && (_second == oSecond || [_second isEqual:other.second]));
	}
	return NO;
}

- (NSUInteger)hash
{
	// xor in a magic value so that way our hash != [nil hash] if both first == nil && second == nil
	return 0xABADBABE ^ [_first hash] ^ [_second hash];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: (%@, %@)>", NSStringFromClass([self class]), self.first, self.second];
}

@end
