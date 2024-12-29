//
//  ContentView.swift
//  Zomigle
//
//  Created by HAHALOSAH on 3/1/24.
//

import SwiftUI
import Darwin

// Zomigle 应用的状态枚举
enum ZomigleStatus {
    case waiting;    // 等待中
    case ready;      // 准备就绪
    case done;       // 完成
    case unavailable;// 不可用
    case failed;     // 失败
}

// 主视图
struct ContentView: View {
    // 状态变量，用于追踪应用当前状态
    @State var status: ZomigleStatus = .waiting
    
    var body: some View {
        VStack {
            Text("淘宝老司机巨魔 iWatch专用")
                .font(.largeTitle)
            Text("版本 1.9 ")
            Spacer()
            if status == .waiting {
                Text("加载中...")
                    .font(.title)
            } else if status == .ready {
                Button(action: {
                    install()
                }) {
                    HStack {
                        Image(systemName: "hammer")
                        Text("点击此处然后截图发我")
                    }
                }
                .font(.title)
            } else if status == .done {
                Button(action: {
                    uninstall()
                }) {
                    HStack {
                        Image(systemName: "hammer.fill")
                        Text("卸载配对支持（没事不要点击）")
                    }
                }
                .font(.title)
                Button(action: {
                    respring()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("现在重启两遍手机，然后去配对手表（如果提示更新手表选择跳过更新手表")
                    }
                }
                .font(.title)
            } else if status == .unavailable {
                Text("无法使用 - 请确保通过 TrollStore 或越狱包管理器安装此应用")
                    .font(.title)
                    .multilineTextAlignment(.center)
            } else {
                Text("失败 - 请联系 @HAHALOSAH 或重新打开应用并重试")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button("如果你不是从淘宝老司机巨魔下单,从别的地方购买使用的这个APP请直接退款!") {
                UIApplication.shared.open(URL(string: "https://m.tb.cn/h.T6sDU1Zv0RA5fCD")!)
            }
            Button("请尊重每个人的劳动成果！") {
                UIApplication.shared.open(URL(string: "https://m.tb.cn/h.T6sDU1Zv0RA5fCD")!)
            }
            Text("恶意仅退款、恶意差评、白嫖党，替我挡灾厄运缠身")
        }
        .padding()
        .onAppear {
            check() // 视图出现时检查状态
        }
    }
    
    // 检查是否是通过 TrollStore 安装
    func isTrollStore() -> Bool {
        // 检查是否有 root 权限
        if getuid() == 0 {
            return true
        }
        
        // 检查是否在 /var/containers/Bundle/Application 目录下
        if let executablePath = Bundle.main.executablePath {
            if executablePath.contains("/var/containers/Bundle/Application") {
                return false
            }
        }
        
        // 检查是否可以访问 TrollStore 特有目录
        if FileManager.default.fileExists(atPath: "/var/containers/Bundle/Application") {
            return true
        }
        
        return false
    }
    
    // 检查应用状态和文件权限
    func check() {
        // 首先检查是否是 TrollStore 安装
        if !isTrollStore() {
            status = .unavailable
            return
        }
        
        // 尝试恢复备份的 NanoRegistry 文件
        do {
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
        } catch {
            NSLog("%@", error as NSError)
        }
        
        // 检查是否有写入权限
        let testPath = "/var/mobile/Library/Preferences/com.test.plist"
        let testData = "test".data(using: .utf8)!
        do {
            try testData.write(to: URL(fileURLWithPath: testPath))
            try FileManager.default.removeItem(atPath: testPath)
        } catch {
            NSLog("权限检查失败: %@", error as NSError)
            status = .unavailable
            return
        }
        
        // 检查备份文件是否存在，存在则表示已安装
        if FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
            status = .done
            return
        }
        status = .ready
    }
    
    // 安装配对支持
    func install() {
        do {
            // 备份原始文件
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup")
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist", toPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup")
            
            // 读取并修改配置文件
            var currentContents = NSMutableDictionary(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup"))
            if currentContents == nil {
                status = .failed
                return
            }
            
            // 修改配对兼容性版本设置
            currentContents!.setObject(1, forKey: "minPairingCompatibilityVersion" as NSCopying)
            currentContents!.setObject(99, forKey: "maxPairingCompatibilityVersion" as NSCopying)
            currentContents!.setObject("", forKey: "IOS_PAIRING_EOL_MIN_PAIRING_COMPATIBILITY_VERSION_CHIPIDS" as NSCopying)
            currentContents!.setObject(1, forKey: "minPairingCompatibilityVersionWithChipID" as NSCopying)
            
            // 保存修改后的配置
            try currentContents?.write(to: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist"))
            currentContents = NSMutableDictionary(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup"))
            if currentContents == nil {
                status = .failed
                return
            }
            currentContents!.setObject(99, forKey: "activityTimeout" as NSCopying)
            check()
        } catch {
            status = .failed
        }
    }
    
    // 卸载配对支持
    func uninstall() {
        // 检查备份文件权限
        if !FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
            status = .failed
            return
        }
        
        do {
            // 恢复原始文件
            if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist") && FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
                try FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
                try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
            }
            
            // 恢复配对同步文件
            if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist") && FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup") {
                try FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist")
                try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist")
            }
            check()
        } catch {
            status = .failed
        }
    }
}

#Preview {
    ContentView()
}
