#import "LynxLinkingModule.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation LynxLinkingModule

+ (NSString *)name {
    return @"LynxLinkingModule";
}

+ (NSDictionary<NSString *, NSString *> *)methodLookup {
    return @{
        @"openURL": NSStringFromSelector(@selector(openURL:callback:)),
        @"openSettings": NSStringFromSelector(@selector(openSettings:)),
        @"sendIntent": NSStringFromSelector(@selector(sendIntent:extras:callback:)),
        @"share": NSStringFromSelector(@selector(share:options:callback:))
    };
}

- (void)openURL:(NSString *)url callback:(void(^)(NSString * _Nullable error))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *nsurl = [NSURL URLWithString:url];
        if (nsurl && [[UIApplication sharedApplication] canOpenURL:nsurl]) {
            [[UIApplication sharedApplication] openURL:nsurl options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    callback(nil);
                } else {
                    callback(@"Failed to open URL");
                }
            }];
        } else {
            callback(@"Invalid URL or cannot open URL");
        }
    });
}

- (void)openSettings:(void(^)(NSString * _Nullable error))callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (settingsURL && [[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    callback(nil);
                } else {
                    callback(@"Failed to open settings");
                }
            }];
        } else {
            callback(@"Cannot open settings");
        }
    });
}

- (void)sendIntent:(NSString *)action extras:(NSArray * _Nullable)extras callback:(void(^)(NSString * _Nullable error))callback {
    // iOS doesn't support Android-style intents. 
    // We'll only handle URL schemes that make sense on iOS, ignore Android-specific actions
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = nil;
        
        // Only handle URL schemes that are meaningful on iOS
        if ([action hasPrefix:@"http://"] || [action hasPrefix:@"https://"] || 
            [action hasPrefix:@"tel:"] || [action hasPrefix:@"mailto:"] ||
            [action hasPrefix:@"sms:"] || [action hasPrefix:@"facetime:"] ||
            [action hasPrefix:@"maps:"] || [action hasPrefix:@"itms:"] ||
            [action hasPrefix:@"itms-apps:"]) {
            
            url = [NSURL URLWithString:action];
        } else if ([action isEqualToString:@"android.intent.action.VIEW"] && extras && extras.count > 0) {
            // Special case: extract URL from Android VIEW intent extras
            NSDictionary *firstExtra = extras[0];
            if ([firstExtra isKindOfClass:[NSDictionary class]]) {
                NSString *value = firstExtra[@"value"];
                if (value && [value isKindOfClass:[NSString class]]) {
                    url = [NSURL URLWithString:value];
                }
            }
        } else {
            // Ignore Android-specific intents that don't translate to iOS
            NSLog(@"[LynxLinking] Ignoring Android-specific intent: %@", action);
            callback(nil); // Success but no-op
            return;
        }
        
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    callback(nil);
                } else {
                    callback(@"Failed to handle intent");
                }
            }];
        } else if (url) {
            callback(@"URL scheme not supported or not allowed");
        } else {
            callback(@"Invalid or unsupported intent action");
        }
    });
}

- (void)share:(NSString * _Nullable)content options:(NSDictionary * _Nullable)options callback:(void(^)(NSString * _Nullable error))callback {
    if (!content) {
        callback(@"Content cannot be null");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *itemsToShare = [NSMutableArray array];
        
        // Handle dialog title
        NSString *dialogTitle = options[@"dialogTitle"];
        if (dialogTitle) {
            [itemsToShare addObject:dialogTitle];
        }
        
        // Handle content
        if ([content hasPrefix:@"file://"] || [content hasPrefix:@"/"]) {
            // Local file
            NSString *filePath = [content hasPrefix:@"file://"] 
                ? [[NSURL URLWithString:content] path] 
                : content;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                [itemsToShare addObject:fileURL];
            } else {
                callback([NSString stringWithFormat:@"File does not exist: %@", filePath]);
                return;
            }
        } else {
            // Text or URL
            if (dialogTitle) {
                NSString *textWithTitle = [NSString stringWithFormat:@"%@\n%@", dialogTitle, content];
                [itemsToShare addObject:textWithTitle];
            } else {
                [itemsToShare addObject:content];
            }
        }
        
        if (itemsToShare.count == 0) {
            callback(@"No items to share");
            return;
        }
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] 
                                               initWithActivityItems:itemsToShare 
                                               applicationActivities:nil];
        
        // Get the root view controller
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        
        // For iPad, we need to set up popover presentation
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            activityVC.popoverPresentationController.sourceView = rootViewController.view;
            activityVC.popoverPresentationController.sourceRect = CGRectMake(
                rootViewController.view.bounds.size.width / 2,
                rootViewController.view.bounds.size.height / 2,
                0, 0
            );
        }
        
        [rootViewController presentViewController:activityVC animated:YES completion:^{
            callback(nil);
        }];
    });
}

@end