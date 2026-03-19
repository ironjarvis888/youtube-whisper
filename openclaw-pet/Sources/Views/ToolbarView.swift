//
//  ToolbarView.swift
//  OpenClawPet
//
//  Top toolbar with quick actions
//

import SwiftUI

struct ToolbarView: View {
    @State private var showWeather = false
    @State private var showStocks = false
    
    var body: some View {
        HStack(spacing: 16) {
            // 天氣按鈕
            ToolbarButton(icon: "cloud.sun", label: "天氣") {
                showWeather.toggle()
            }
            .popover(isPresented: $showWeather) {
                WeatherPopoverView()
            }
            
            // 股市按鈕
            ToolbarButton(icon: "chart.line.uptrend.xyaxis", label: "股市") {
                showStocks.toggle()
            }
            .popover(isPresented: $showStocks) {
                StocksPopoverView()
            }
            
            // 設定按鈕
            ToolbarButton(icon: "gearshape", label: "設定") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct ToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption2)
            }
            .frame(width: 50, height: 40)
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

struct WeatherPopoverView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("台北", systemImage: "location")
            Label("26°C 晴朗", systemImage: "sun.max")
            Label("濕度 65%", systemImage: "humidity")
            Label("風速 12 km/h", systemImage: "wind")
        }
        .padding()
        .frame(width: 180)
    }
}

struct StocksPopoverView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("台積電")
                Spacer()
                Text("+2.5%")
                    .foregroundColor(.green)
            }
            HStack {
                Text("鴻海")
                Spacer()
                Text("-0.8%")
                    .foregroundColor(.red)
            }
            HStack {
                Text("大盤")
                Spacer()
                Text("+1.2%")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(width: 180)
    }
}

#Preview {
    ToolbarView()
}
