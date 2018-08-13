#import "Measurement.h"
#import "Result.h"
#import "TestUtility.h"

@implementation Measurement
@dynamic name, startTime, duration, ip, asn, asnName, country, networkName, networkType, state, anomaly, input, category, result, testKeys;
@synthesize testKeysObj = _testKeysObj;

+ (NSDictionary *)defaultValuesForEntity {
    //defailt test to failure in case onEntry is never called
    return @{@"startTime": [NSDate date], @"duration" : [NSNumber numberWithInt:0], @"anomaly" : [NSNumber numberWithBool:FALSE]};
}

/*
    Three scenarios:
    I'm running the test, I start the empty summary, I add stuff and save
    I'm running the test, there is data in the summary, I add stuff and save
 I have to get the sum(no(nonatomic) natomic) mary of an old test and don't modify it
*/
- (TestKeys*)testKeysObj{
    if (!_testKeysObj){
        if (self.testKeys){
            NSError *error;
            NSData *data = [self.testKeys dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil) {
                NSLog(@"Error parsing JSON: %@", error);
                _testKeysObj = [[TestKeys alloc] init];
            }
            /*
             InCodeMappingProvider *mappingProvider = [[InCodeMappingProvider alloc] init];
             ObjectMapper *mapper = [[ObjectMapper alloc] init];
             mapper.mappingProvider = mappingProvider;
             JsonResult *json = [mapper objectFromSource:jsonDic toInstanceOfClass:[JsonResult class]];
             */
            _testKeysObj = [TestKeys objectFromDictionary:jsonDic];
        }
        else
            _testKeysObj = [[TestKeys alloc] init];
    }
    return _testKeysObj;
}

- (void)setTestKeysObj:(TestKeys *)testKeysObj{
    _testKeysObj = testKeysObj;
    self.testKeys = [self.testKeysObj getJsonStr];
}

- (NSString*)getFile:(NSString*)ext{
    //log files are unique for web_connectivity test
    if ([self.name isEqualToString:@"web_connectivity"] && [ext isEqualToString:@"log"]){
        return [NSString stringWithFormat:@"%@-%@.%@", self.result.name, self.result.Id, ext];
    }
    return [NSString stringWithFormat:@"%@-%@.%@", self.result.name, self.Id, ext];
}

-(NSString*)getReportFile{
    return [self getFile:@"json"];
}

-(NSString*)getLogFile{
    return [self getFile:@"log"];
}

-(void)save{
    [self commit];
    /*
    NSLog(@"---- START LOGGING MEASUREMENT OBJECT----");
    NSLog(@"%@", self);
    NSLog(@"---- END LOGGING MEASUREMENT OBJECT----");
     */
}

-(void)deleteObject{
    [TestUtility removeFile:[self getLogFile]];
    [TestUtility removeFile:[self getReportFile]];
    [self remove];
}

@end
