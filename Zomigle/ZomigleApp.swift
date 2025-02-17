//
//  ZomigleApp.swift
//  Zomigle
//
//  Created by HAHALOSAH on 3/1/24.
//

import SwiftUI

@main
struct ZomigleApp: App {
    init() {
        // 在应用启动时设置 TrollStore 环境
        setTrollStoreEnvironment()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
