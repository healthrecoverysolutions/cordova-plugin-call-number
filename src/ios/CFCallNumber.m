#import <Cordova/CDVPlugin.h>
#import "CFCallNumber.h"

@implementation CFCallNumber

+ (BOOL)available {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
}

- (void) callNumber:(CDVInvokedUrlCommand*)command {

    NSString* number = [command.arguments objectAtIndex:0];

    number = [number stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    if (![number hasPrefix:@"tel:"]) {
        number = [NSString stringWithFormat:@"tel:%@", number];
    }

    NSURL *url = [NSURL URLWithString:number];

    if (url == nil || ![[UIApplication sharedApplication] canOpenURL:url]) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"InvalidPhoneNumberOrCannotOpenURL"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            CDVPluginResult* pluginResult;
            if (success) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    });
}

- (void) isCallSupported:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* pluginResult = [CDVPluginResult
            resultWithStatus:CDVCommandStatus_OK
            messageAsBool:[CFCallNumber available]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
