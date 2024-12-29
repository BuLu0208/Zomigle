//
//  ContentView.swift
//  Zomigle
//
//  Created by HAHALOSAH on 3/1/24.
//

import SwiftUI
import Foundation

// 定义应用程序的状态枚举
enum ZomigleStatus {
    case waiting
    case needPassword
    case ready
    case done
    case unavailable
    case failed
}

// 添加密码管理器
class PasswordManager {
    static let shared = PasswordManager()
    private let passwordURL = "http://124.70.142.143/releases/latest/download/password.txt"
    
    private var cachedPassword: String?
    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5分钟缓存
    
    private init() {}
    
    func getCachedPassword() -> String? {
        guard let lastFetch = lastFetchTime,
              let cached = cachedPassword,
              Date().timeIntervalSince(lastFetch) < cacheTimeout else {
            return nil
        }
        return cached
    }
    
    func getPassword() async throws -> String {
        if let cached = getCachedPassword() {
            return cached
        }
        
        guard let url = URL(string: passwordURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let password = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        cachedPassword = password
        lastFetchTime = Date()
        return password
    }
}

struct ContentView: View {
    @State var status: ZomigleStatus = .waiting
    @State private var password: String = ""
    @State private var showPasswordAlert = false
    @State private var passwordError = false
    
    var body: some View {
        VStack {
            Text("淘宝老司机巨魔 iWatch专用")
                .font(.largeTitle)
            Text("版本 1.9")
            Spacer()
            
            if status == .waiting {
                Text("加载中...")
                    .font(.title)
            } else if status == .needPassword {
                VStack(spacing: 20) {
                    SecureField("请输入密码", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        Task {
                            if let correctPassword = await fetchPassword() {
                                if password == correctPassword {
                                    status = .ready
                                    check()
                                } else {
                                    passwordError = true
                                    showPasswordAlert = true
                                }
                            } else {
                                showPasswordAlert = true
                            }
                        }
                    }) {
                        Text("验证")
                            .font(.title)
                    }
                }
                .alert(isPresented: $showPasswordAlert) {
                    Alert(
                        title: Text("错误"),
                        message: Text(passwordError ? "密码错误，请联系淘宝老司机巨魔获取密码" : "无法连接服务器，请检查网络连接"),
                        dismissButton: .default(Text("确定"))
                    )
                }
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
            status = .needPassword
        }
    }
    
    // 从服务器获取密码
    func fetchPassword() async -> String? {
        do {
            return try await PasswordManager.shared.getPassword()
        } catch {
            print("获取密码失败: \(error)")
            return nil
        }
    }
    
    // 检查应用程序状态
    func check() {
        print("开始检查权限...")
        
        // 检查是否是 TrollStore 安装
        let trollStorePath = "/var/containers/Bundle/Application/.trollstore_installed"
        if FileManager.default.fileExists(atPath: trollStorePath) {
            print("检测到 TrollStore 标记")
        } else {
            print("未检测到 TrollStore 标记")
        }
        
        // 检查是否有根目录访问权限
        if FileManager.default.fileExists(atPath: "/var/mobile") {
            print("有根目录访问权限")
        } else {
            print("无根目录访问权限")
        }
        
        // 检查 Preferences 目录
        let prefsPath = "/var/mobile/Library/Preferences"
        print("检查目录: \(prefsPath)")
        
        if FileManager.default.fileExists(atPath: prefsPath) {
            print("Preferences 目录存在")
        } else {
            print("Preferences 目录不存在")
            status = .unavailable
            return
        }
        
        // 尝试写入测试
        let testPath = "\(prefsPath)/zomigle_test.txt"
        do {
            print("尝试写入测试文件: \(testPath)")
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            print("写入测试成功")
            try FileManager.default.removeItem(atPath: testPath)
            print("删除测试文件成功")
        } catch {
            print("写入测试失败: \(error.localizedDescription)")
            status = .unavailable
            return
        }
        
        // 检查备份文件
        let backupPath = "\(prefsPath)/com.apple.NanoRegistry.plist.backup"
        if FileManager.default.fileExists(atPath: backupPath) {
            print("检测到备份文件，状态设为已完成")
            status = .done
        } else {
            print("未检测到备份文件，状态设为就绪")
            status = .ready
        }
        
        // 尝试恢复备份
        do {
            try FileManager.default.moveItem(
                atPath: "\(prefsPath)/com.apple.NanoRegistry.plist.backup",
                toPath: "\(prefsPath)/com.apple.NanoRegistry.plist"
            )
            print("恢复备份成功")
        } catch {
            print("恢复备份失败或无需恢复: \(error.localizedDescription)")
        }
    }
    
    // 安装配对支持
    func install() {
        do {
            // 备份原始配置文件
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup")
            try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist", toPath: "/var/mobile/Library/Preferences/com.apple.pairedsync.plist.backup")
            
            // 创建新的配置
            let dict: [String: Any] = [
                "minPairingCompatibilityVersion": 1,
                "maxPairingCompatibilityVersion": 38,
                "IOS_PAIRING_EOL_MIN_PAIRING_COMPATIBILITY_VERSION_CHIPIDS": "",
                "minPairingCompatibilityVersionWithChipID": 1,
                "activityTimeout": 99,
                "lastRestoreIdentifier_state": 0,
            ]
            
            // 保存新配置
            let data = try PropertyListSerialization.data(
                fromPropertyList: dict,
                format: .xml,
                options: 0
            )
            
            // 写入新的配置文件
            try data.write(to: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist"))
            
            check()
        } catch {
            status = .failed
        }
    }
    
    // 移除配对支持
    func uninstall() {
        // 检查备份文件是否可写
        if !FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
            status = .failed
            return
        }
        
        do {
            // 恢复 NanoRegistry 配置文件
            if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist") && FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup") {
                try FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
                try FileManager.default.moveItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist.backup", toPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
            }
            
            // 恢复 pairedsync 配置文件
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
