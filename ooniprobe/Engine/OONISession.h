#import <Foundation/Foundation.h>
#import "OONIContext.h"
#import "OONIGeolocateResults.h"
#import "OONISubmitResults.h"

/**
 * OONISession contains shared state for running experiments and/or other
 * related task (e.g. geolocation). Note that a OONISession is not meant to
 * be a long running instance. The expected usage is that you create a new
 * session, use it immediately, and then forget about it.
 */
@protocol OONISession
/** geolocate returns the probe geolocation. */
- (OONIGeolocateResults*) geolocate:(OONIContext*) ctx error:(NSError **)error;

/** maybeUpdateResources updates resources if needed. */
- (void) maybeUpdateResources:(OONIContext*) ctx error:(NSError **)error;

/** newContext creates a new OONIContext instance. */
- (OONIContext*) newContext;

/**
 * newContextWithTimeout creates a new OONIContext instance that times
 * out after the specified number of seconds. A zero or negative timeout
 * is equivalent to create a OONIContext without a timeout.
 */
- (OONIContext*) newContextWithTimeout:(long)timeout;

/** submit submits a measurement and returns the submission results. */
- (OONISubmitResults*) submit:(OONIContext*) ctx measurement:(NSString*) measurement error:(NSError **)error;

@end
