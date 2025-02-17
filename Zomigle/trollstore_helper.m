#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <unistd.h>
#import <sys/stat.h>

BOOL isTrollStore(void) {
    // 检查多个 TrollStore 标记
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    
    // 检查路径权限
    if (access("/var/mobile/Library/Preferences", R_OK) != 0) {
        return NO;
    }
    
    // 检查是否是 TrollStore 安装
    NSString *trollstorePath = [bundlePath stringByAppendingPathComponent:@".trollstore_installed"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:trollstorePath]) {
        return YES;
    }
    
    // 检查可执行文件标记
    NSString *executableMark = [executablePath stringByAppendingString:@".installed_trollstore"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:executableMark]) {
        return YES;
    }
    
    return NO;
}

void setTrollStoreEnvironment(void) {
    // 设置环境变量
    setenv("TROLLSTORE", "1", 1);
    
    // 创建 TrollStore 标记文件
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *trollstorePath = [bundlePath stringByAppendingPathComponent:@".trollstore_installed"];
    [[NSFileManager defaultManager] createFileAtPath:trollstorePath contents:nil attributes:nil];
    
    // 设置文件权限
    NSString *prefsPath = @"/var/mobile/Library/Preferences";
    NSString *nanoRegistryPath = @"/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist";
    
    chmod([prefsPath UTF8String], 0755);
    chmod([nanoRegistryPath UTF8String], 0644);
    
    // 创建符号链接
    NSString *bundlePrefsPath = [bundlePath stringByAppendingPathComponent:@"Library/Preferences"];
    [[NSFileManager defaultManager] createDirectoryAtPath:bundlePrefsPath withIntermediateDirectories:YES attributes:nil error:nil];
    symlink([prefsPath UTF8String], [[bundlePrefsPath stringByAppendingPathComponent:@"mobile"] UTF8String]);
} 