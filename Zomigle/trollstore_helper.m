#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <unistd.h>
#import <sys/stat.h>

BOOL isTrollStore(void) {
    // 检查 TrollStore 特定文件
    return (access("/var/mobile/Library/Preferences", R_OK) == 0) &&
           (access("/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist", R_OK) == 0);
}

void setTrollStoreEnvironment(void) {
    // 设置环境变量
    setenv("TROLLSTORE", "1", 1);
    // 设置文件权限
    chmod("/var/mobile/Library/Preferences", 0755);
    chmod("/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist", 0644);
} 