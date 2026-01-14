import SwiftUI

// MARK: 🌸 Hồ Sen - Phiên bản Mượt mà & Không lộ mép
final class LotusPondView {
    static func show(
        halfSpace: CGFloat,
        lotusCount: Int,
        onOpenPGNButtonTapped: @escaping () -> Void
    ) -> some View {
        LotusPondScene(
            halfSpace: halfSpace,
            onOpenPGNButtonTapped: onOpenPGNButtonTapped,
            lotusCount: lotusCount
        )
    }

    private struct LotusPondScene: View {
        var halfSpace: CGFloat
        var onOpenPGNButtonTapped: () -> Void
        var lotusCount: Int
        
        @State private var floatingLotusConfigs: [FloatingLotusConfig] = []
        @State private var isShowingInfo = false // Trạng thái hiển thị Alert

        var body: some View {
            GeometryReader { geo in
                ZStack {
                    // 🌊 Nền nước
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "32ADE6"), Color(hex: "007AFF"),  Color(hex: "#AF52DE")]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea()
                    
                    // ✨ Phản chiếu ánh sáng
                    MovingLightReflection()
                        .blendMode(.screen)
                        .opacity(0.15)
                    
                    // 🌫️ Sóng động
                    Group {
                        BeautifulWaveLayer(amplitude: 6, speed: 0.4, color: Color(red: 0.0, green: 0.1, blue: 0.15), opacity: 0.4, halfSpace: geo.size.height)
                            .blendMode(.multiply)
                            .offset(y: 15)
                        
                        BeautifulWaveLayer(amplitude: 9, speed: 0.6, color: Color.cyan, opacity: 0.18, halfSpace: geo.size.height)
                            .offset(y: 10)
                            .blendMode(.overlay)
                        
                        BeautifulWaveLayer(amplitude: 4, speed: 0.9, color: .white, opacity: 0.1, halfSpace: geo.size.height)
                            .blendMode(.screen)
                    }
                    .frame(width: geo.size.width + 100)
                    .drawingGroup()

                    // 🌸 Hoa sen
                    ForEach(floatingLotusConfigs) { config in
                        FloatingLotus(
                            config: config,
                            viewWidth: geo.size.width
                        )
                        .frame(width: 50, height: 50)
                        .position(x: geo.size.width / 2, y: halfSpace * config.yPositionMultiplier)
                    }
                    
           
                }
                .clipped()
                .onAppear {
                    setupConfigs()
                }
                .onChange(of: lotusCount) { _ in
                    setupConfigs()
                }
            }
            .frame(height: halfSpace)
            .overlay(
                HStack {
                    // ℹ️ Nút Info (thay cho Trophy)
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowingInfo = true
                        }
                    }) {
                        Image(systemName: "info.circle.fill") // Đổi biểu tượng
                            .resizable()
                            .scaledToFit()
                            .frame(width: 0, height: 0)
                            .foregroundColor(.white)
                            .shadow(color: .cyan.opacity(0.7), radius: 8)
                            .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    // 🔗 Nút Share
                    Button(action: {
                        LotusPondView.shareGame()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .shadow(color: .cyan.opacity(0.7), radius: 8)
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                    }
                }
            )
        }
        
        private func setupConfigs() {
            floatingLotusConfigs = (0..<lotusCount).map { _ in FloatingLotusConfig() }
        }
    }

    // MARK: - 📱 Custom App Info Alert
    private struct AppInfoAlert: View {
        @Binding var isPresented: Bool
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isPresented = false } }
                
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 45))
                            .foregroundColor(.cyan)
                        
                        Text("MUSIC COMPOSER")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Ứng dụng hỗ trợ sáng tác nhạc chuyên nghiệp, giúp bạn ghi lại những giai điệu tuyệt vời ngay trên thiết bị của mình.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    
                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Text("ĐÓNG")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(Color.cyan.opacity(0.6))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 30)
                .frame(width: 280)
                .background(Color(white: 0.1))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                )
            }
        }
    }

    // --- Các phần cấu hình Hoa Sen và Sóng nước giữ nguyên từ file gốc của bạn ---
    private struct FloatingLotusConfig: Identifiable {
        let id = UUID()
        let travelDuration: Double = Double.random(in: 40...60)
        let bobbingDuration: Double = Double.random(in: 3...5)
        let rotation: Double = Double.random(in: -10...10)
        let startFromLeft: Bool = .random()
        let yPositionMultiplier: CGFloat = CGFloat.random(in: 0.3...0.5)
    }

    private struct FloatingLotus: View {
        let config: FloatingLotusConfig
        let viewWidth: CGFloat
        @State private var bobbingOffset: CGFloat = 0
        @State private var horizontalOffset: CGFloat = 0

        var body: some View {
            ZStack {
                Image("lotus_flower")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(y: -1)
                    .opacity(0.25)
                    .blur(radius: 1.5)
                    .offset(y: 32 + bobbingOffset)

                Image("lotus_flower")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(config.rotation))
                    .offset(y: bobbingOffset)
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            }
            .offset(x: horizontalOffset)
            .onAppear { startFloating() }
        }

        private func startFloating() {
            let startX = config.startFromLeft ? -viewWidth / 2 - 80 : viewWidth / 2 + 80
            horizontalOffset = startX
            withAnimation(.linear(duration: config.travelDuration).repeatForever(autoreverses: false)) {
                horizontalOffset = -startX
            }
            withAnimation(.easeInOut(duration: config.bobbingDuration).repeatForever(autoreverses: true)) {
                bobbingOffset = 10
            }
        }
    }

    private static func shareGame() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        let appLink = URL(string: "https://apps.apple.com/app/song-maker-ai/6757778577")!
        let activityVC = UIActivityViewController(activityItems: [appLink], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = rootVC.view
        rootVC.present(activityVC, animated: true)
    }

    private struct BeautifulWaveLayer: View {
        let amplitude: CGFloat
        let speed: Double
        let color: Color
        let opacity: Double
        let halfSpace: CGFloat

        var body: some View {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let phase = CGFloat(time * speed)
                    let baseHeight = halfSpace * 0.5
                    var path = Path()
                    path.move(to: CGPoint(x: -50, y: baseHeight))
                    for x in stride(from: -50, through: size.width + 50, by: 10) {
                        let y = sin((x / (size.width)) * 3 * .pi + phase) * amplitude
                        path.addLine(to: CGPoint(x: x, y: baseHeight + y))
                    }
                    path.addLine(to: CGPoint(x: size.width + 50, y: size.height))
                    path.addLine(to: CGPoint(x: -50, y: size.height))
                    path.closeSubpath()
                    context.fill(path, with: .color(color.opacity(opacity)))
                }
            }
        }
    }

    private struct MovingLightReflection: View {
        @State private var move = false
        var body: some View {
            LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.15), .clear]), startPoint: .leading, endPoint: .trailing)
                .frame(width: 400)
                .rotationEffect(.degrees(15))
                .offset(x: move ? 500 : -500)
                .onAppear {
                    withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) { move = true }
                }
        }
    }
}


