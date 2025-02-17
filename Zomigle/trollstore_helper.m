#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <unistd.h>
#import <sys/stat.h>

BOOL isTrollStore(void) {
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    NSString *trollStoreMark = [executablePath stringByAppendingString:@".installed_trollstore"];
    return [[NSFileManager defaultManager] fileExistsAtPath:trollStoreMark];
}

void setTrollStoreEnvironment(void) {
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    NSString *trollStoreMark = [executablePath stringByAppendingString:@".installed_trollstore"];
    [[NSFileManager defaultManager] createFileAtPath:trollStoreMark contents:nil attributes:nil];
    
    // 设置文件权限
    NSString *prefsPath = @"/var/mobile/Library/Preferences";
    NSString *nanoRegistryPath = @"/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist";
    
    // 创建符号链接
    NSString *bundlePrefsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Library/Preferences"];
    [[NSFileManager defaultManager] createDirectoryAtPath:bundlePrefsPath withIntermediateDirectories:YES attributes:nil error:nil];
    symlink([prefsPath UTF8String], [[bundlePrefsPath stringByAppendingPathComponent:@"mobile"] UTF8String]);
    
    chmod([prefsPath UTF8String], 0755);
    chmod([nanoRegistryPath UTF8String], 0644);
} 