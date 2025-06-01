# ZenAkku
ZenAkku - Klarheit statt Ablenkung
import SwiftUI
import MachO
import Darwin
import IOKit.ps

/// Ein Wabi-Sabi-Ring mit variablem Fortschritt (0…1).
struct WabiRing: Shape {
    var progress: Double
    var variability: CGFloat = 2.8

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let segments = 100
        for i in 0..<segments {
            let t = Double(i) / Double(segments)
            guard t <= progress else { continue }
            let start = Angle(degrees: -90 + 360 * t)
            let end = Angle(degrees: -90 + 360 * (t + 1 / Double(segments)))
            var subpath = Path()
            subpath.addArc(center: center,
                           radius: radius,
                           startAngle: start,
                           endAngle: end,
                           clockwise: false)
            let width = CGFloat.random(in: 2 - variability...3 + variability)
            path.addPath(subpath.strokedPath(StrokeStyle(lineWidth: width, lineCap: .round)))
        }
        return path
    }

    var animatableData: Double { progress }
}

struct ZenAkkuWabiSabiView: View {
    // Akku-Zustand
    @State private var batteryPercent: Double = 0
    @State private var isCharging = false
    @State private var chargeTime = "--:--"
    
    // Akku-Lade-Animation
    @State private var isPulsing = false

    // SSD-Status (GB)
    @State private var usedSpaceGB: Double = 0
    @State private var freeSpaceGB: Double = 0
    @State private var diskPercent: Double = 0

    // RAM-Status (GB)
    @State private var usedMemGB: Double = 0
    @State private var freeMemGB: Double = 0
    @State private var memPercent: Double = 0

    @State private var toastMessage: String? = nil
    @State private var currentQuote: String = QuoteProvider.randomQuote

    // Hilfs-Properties für Akku-Icon und Text
    private var topIcon: String { isCharging ? "powerplug.fill" : "battery.100" }
    private var topText: String { isCharging ? "Netzteil • ON" : "Akku • ON" }
    
    // Timer, der alle 5 Sekunden feuert
    private let batteryTimer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Sehr dezente Hintergrund-Textur
            JapaneseDottedBackground(
                backgroundColor: Color(red: 0.09, green: 0.07, blue: 0.10),
                dotColor: Color(red: 0.80, green: 0.82, blue: 0.85, opacity: 0.2),
                dotSize: 1,
                dotSpacing: 30,
                rowOffset: 8
            ) // ← schließende Klammer für JapaneseDottedBackground

            // ───────────────────────────────────────────────
            //  Inhalts-VStack
            VStack(spacing: 12) {
                // 1) TOP-BAR: Akku-Icon + Text links, Prozente rechts
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: topIcon)
                        Text(topText)
                            .font(.system(size: 10, weight: .light, design: .monospaced))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text("\(Int(batteryPercent * 100))%")
                        .font(.system(size: 10, weight: .light, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)

                // 2) Zufalls-Zitat
                Text(currentQuote)
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal)
                    .onAppear(perform: updateQuote)

                // 3) DREI RINGE: Akku, SSD, RAM nebeneinander
                HStack(spacing: 24) {
                    // Akku-Ring (mit Prozent-Text und Icon in der Mitte)
                    VStack(spacing: 6) {
                        ZStack {
                            // Hintergrund-Ring (grau)
                            WabiRing(progress: 1.0)
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 100, height: 100)

                            // Farbiger Ring je nach Akku-Fortschritt
                            WabiRing(progress: batteryPercent)
                                .foregroundColor(.yellow.opacity(0.6))
                                .frame(width: 100, height: 100)
                                .scaleEffect(isCharging && isPulsing ? 1.1 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: isPulsing
                                )
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: batteryPercent)

                            // Prozent-Text und Icon als VStack (zentriert über den Ringen)
                            VStack(spacing: 4) {
                                Text("\(Int(batteryPercent * 100))%")
                                    .font(.system(size: 11, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)

                                Image(systemName: "battery.100")
                                    .font(.system(size: 16, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // SSD-Ring (mit Prozent-Text und Icon in der Mitte)
                    VStack(spacing: 6) {
                        ZStack {
                            WabiRing(progress: 1.0)
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 100, height: 100)

                            WabiRing(progress: diskPercent)
                                .foregroundColor(.green.opacity(0.6))
                                .frame(width: 100, height: 100)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: diskPercent)

                            VStack(spacing: 4) {
                                Text("\(Int(diskPercent * 100))%")
                                    .font(.system(size: 11, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)

                                Image(systemName: "memorychip")
                                    .font(.system(size: 16, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    // RAM-Ring (mit Prozent-Text und Icon unterhalb)
                    VStack(spacing: 6) {
                        ZStack {
                            WabiRing(progress: 1.0)
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: 100, height: 100)

                            WabiRing(progress: memPercent)
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 100, height: 100)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: memPercent)

                            VStack(spacing: 4) {
                                Text("\(Int(memPercent * 100))%")
                                    .font(.system(size: 11, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)

                                Image(systemName: "bolt.heart.fill")
                                    .font(.system(size: 16, weight: .light, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)

                // 4) Detaillierte Grid-Liste unten
                Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 6) {
                    GridRow {
                        HStack(spacing: 4) {
                            // Platzhalter, wenn du oben Icon/Text weglässt
                        }
                        Text("")
                    }
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: isCharging ? "clock.fill" : "clock")
                                .foregroundColor(isCharging ? .green : .gray)
                            Text(isCharging ? "Ladezeit" : "Akkuzeit")
                        }
                        Text(chargeTime)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: "memorychip")
                            Text("SSD Belegt")
                        }
                        Text(String(format: "%.1f GB", usedSpaceGB))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.red.opacity(0.7))
                    }
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: "memorychip.fill")
                            Text("SSD Frei")
                        }
                        Text(String(format: "%.1f GB", freeSpaceGB))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.green.opacity(0.7))
                    }
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.heart.fill")
                            Text("RAM Belegt")
                        }
                        Text(String(format: "%.1f GB", usedMemGB))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    GridRow {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.heart")
                            Text("RAM Frei")
                        }
                        Text(String(format: "%.1f GB", freeMemGB))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .font(.system(size: 10, weight: .light, design: .monospaced))

                // 5) Buttons
                HStack(spacing: 12) {
                    Button("Aktualisieren", action: refreshAll)
                        .buttonStyle(MonoButtonStyle())
                    Button("Cache bereinigen", action: clearCache)
                        .buttonStyle(MonoButtonStyle())
                }
            } // ← Ende des VStack(spacing: 12)
            .padding(24)

            // ───────────────────────────────────────────────
            // Optional: Toast-Meldung direkt über allem
            if let msg = toastMessage {
                Text(msg)
                    .font(.system(size: 12, weight: .light, design: .monospaced))
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity)
                    .zIndex(1)
            }
        } // ← ← ← Hier endet der ZStack

        // ───────────────────────────────────────────────────────────────────
        // D I E   D R E I   M O D I F I E R   für den ZStack:
        .onAppear {
            refreshAll()
            if isCharging { isPulsing = true }
        }
        .onChange(of: isCharging) { newValue in
            isPulsing = newValue
        }
        .onReceive(batteryTimer) { _ in
            refreshAll()
        }
    } // ← Hier endet body: some View

    // ───────────────────────────────────────────────────────────────────
    // Funktionen zum Einlesen der Daten (innerhalb der struct)
    // ───────────────────────────────────────────────────────────────────
    private func updateQuote() {
        let hour = Calendar.current.component(.hour, from: Date())
        let index = hour % QuoteProvider.quotes.count
        currentQuote = QuoteProvider.quotes[index]
    }

    private func refreshAll() {
        fetchBatteryStatus()
        fetchDiskStatus()
        fetchMemoryStatus()
    }

    func fetchBatteryStatus() {
        DispatchQueue.global(qos: .utility).async {
            guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
                  let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
                  let source = sources.first,
                  let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any]
            else {
                return
            }

            let isChargingNew = (desc[kIOPSIsChargingKey] as? Bool) ?? false
            let minutes: Int = {
                if isChargingNew {
                    return (desc[kIOPSTimeToFullChargeKey] as? Int) ?? -1
                } else {
                    return (desc[kIOPSTimeToEmptyKey] as? Int) ?? -1
                }
            }()
            let timeStr: String = {
                guard minutes >= 0 else { return "--:--" }
                let h = minutes / 60
                let m = minutes % 60
                return String(format: "%d:%02d", h, m)
            }()

            DispatchQueue.main.async {
                self.isCharging = isChargingNew
                self.chargeTime = timeStr
                if let cap = desc[kIOPSCurrentCapacityKey] as? Int,
                   let max = desc[kIOPSMaxCapacityKey] as? Int {
                    self.batteryPercent = Double(cap) / Double(max)
                }
            }
        }
    }

    private func fetchDiskStatus() {
        DispatchQueue.global(qos: .utility).async {
            if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: "/"),
               let free = attrs[.systemFreeSize] as? Double,
               let total = attrs[.systemSize] as? Double {
                let used = total - free
                let usedGB = used / 1_073_741_824
                let freeGB = free / 1_073_741_824
                let percent = used > 0 ? used / total : 0

                DispatchQueue.main.async {
                    self.usedSpaceGB = usedGB
                    self.freeSpaceGB = freeGB
                    self.diskPercent = percent
                }
            }
        }
    }

    private func fetchMemoryStatus() {
        DispatchQueue.global(qos: .utility).async {
            var size: UInt64 = 0
            var len = MemoryLayout<UInt64>.size
            sysctlbyname("hw.memsize", &size, &len, nil, 0)
            let totalGB = Double(size) / 1_073_741_824

            var stats = vm_statistics64()
            var count = mach_msg_type_number_t(
                MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
            )
            _ = withUnsafeMutablePointer(to: &stats) { ptr in
                ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
                }
            }

            let freePages = Double(stats.free_count)
            let pageSize = Double(vm_kernel_page_size)
            let freeMB = freePages * pageSize / (1024 * 1024)
            let freeGB = freeMB / 1024
            let usedGB = totalGB - freeGB
            let ratio = totalGB > 0 ? usedGB / totalGB : 0

            DispatchQueue.main.async {
                self.freeMemGB = freeGB
                self.usedMemGB = usedGB
                self.memPercent = ratio
            }
        }
    }

    private func clearCache() {
        DispatchQueue.global(qos: .utility).async {
            _ = shell(["/usr/bin/env", "rm", "-rf", "${HOME}/Library/Caches/*"])
            fetchDiskStatus()
            DispatchQueue.main.async {
                toastMessage = "Cache bereinigt"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { toastMessage = nil }
                }
            }
        }
    }
}

// Hilfsfunktion für Shell‐Aufrufe
private func shell(_ args: [String]) -> [String] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: args[0])
    task.arguments = Array(args.dropFirst())
    let pipe = Pipe()
    task.standardOutput = pipe
    try? task.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)?
        .split(separator: "\n").map(String.init) ?? []
}

// Preview
struct ZenAkkuWabiSabiView_Previews: PreviewProvider {
    static var previews: some View {
        ZenAkkuWabiSabiView()
            .frame(width: 360, height: 640)
    }
}

// Monospaced Button Style
struct MonoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .light, design: .monospaced))
            .foregroundColor(.primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 25)
            .background(
                configuration.isPressed
                    ? Color.white.opacity(0.2)
                    : Color.white.opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
