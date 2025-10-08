#import <Foundation/Foundation.h>
#import <Lynx/LynxModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface LynxLinkingModule : NSObject <LynxModule>

@property (class, nonatomic, strong, nullable) NSString *initialURL;

@end

NS_ASSUME_NONNULL_END