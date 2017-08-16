//
//  DictionaryUtility.m
//  ooniprobe
//
//  Created by Lorenzo Primiterra on 06/08/17.
//  Copyright © 2017 Simone Basso. All rights reserved.
//

#import "DictionaryUtility.h"

@implementation DictionaryUtility


+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

+ (NSDictionary*)getParametersFromDict:(NSDictionary*)dict{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *key in [dict allKeys]){
        NSString *current = [dict objectForKey:key];
        NSError *error;
        NSData *data = [current dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error == nil){
            [parameters setObject:dictionary forKey:key];
            //NSLog(@"json dictionary for key %@ : %@", key, dictionary);
        }
        else{
            [parameters setObject:current forKey:key];
            //NSLog(@"json object for key %@ : %@", key, current);
            //NSLog(@"error: %@", error);
        }
    }
    return parameters;
}
@end
