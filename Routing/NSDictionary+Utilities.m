//
//  NSDictionary+Utilities.m
//  GRouting
//
//  Created by Joseph Lin on 9/7/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "NSDictionary+Utilities.h"

@implementation NSDictionary (Utilities)

- (NSString*)queryString
{
    NSMutableArray* pairs = [NSMutableArray arrayWithCapacity:[self count]];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, obj];
        [pairs addObject:pair];
    }];
    
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return query;
}


@end
