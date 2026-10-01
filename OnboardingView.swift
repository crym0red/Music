import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedFugaciousOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0
    private let pages = [
        ("Fugacious", "Off the record.\nBy design.", "Your music, your way."),
        ("Organize", "Build a library\nthat feels like yours.", "Pin albums, playlists, and the tracks you never want to lose."),
        ("Listen", "Stay in the moment.", "A focused player designed around the music, not the noise.")
    ]
    var body: some View {
        ZStack { OnboardingBackdrop()
            VStack(spacing: 0) {
                HStack { Spacer(); Button(page == pages.count - 1 ? "Done" : "Skip") { finish() }.font(.system(size:14,weight:.semibold)).foregroundStyle(.white.opacity(0.62)).padding(.horizontal,22).padding(.top,20) }
                Spacer(minLength:30)
                Image("FugaciousMark").resizable().scaledToFit().frame(width:112,height:112).clipShape(RoundedRectangle(cornerRadius:26,style:.continuous)).shadow(color:.purple.opacity(0.28),radius:24,x:0,y:12)
                Text(pages[page].0).font(.system(size:42,weight:.bold,design:.rounded)).foregroundStyle(.white)
                Text(pages[page].1).font(.system(size:20,weight:.medium,design:.rounded)).foregroundStyle(.white.opacity(0.82)).multilineTextAlignment(.center).lineSpacing(5).padding(.top,14)
                Text(pages[page].2).font(.system(size:14,design:.rounded)).foregroundStyle(.white.opacity(0.45)).multilineTextAlignment(.center).padding(.horizontal,42).padding(.top,16)
                Spacer()
                HStack(spacing:7) { ForEach(0..<pages.count,id:\.self) { i in Capsule().fill(i == page ? .white : .white.opacity(0.22)).frame(width:i == page ? 22 : 7,height:7) } }.padding(.bottom,18)
                Button { if page < pages.count - 1 { withAnimation(.easeInOut(duration:0.35)) { page += 1 } } else { finish() } } label: { Text(page == pages.count - 1 ? "Enter Fugacious" : "Continue").font(.system(size:16,weight:.semibold)).frame(maxWidth:.infinity).padding(.vertical,16).background(RoundedRectangle(cornerRadius:16,style:.continuous).fill(.white.opacity(0.12))).foregroundStyle(.white) }.padding(.horizontal,20).padding(.bottom,26) }
        }.preferredColorScheme(.dark)
    }
    private func finish() { withAnimation(.easeInOut(duration:0.3)) { hasCompletedOnboarding = true } }
}
private struct OnboardingBackdrop: View {
    var body: some View { GeometryReader { proxy in ZStack {
        LinearGradient(colors:[Color(red:0.015,green:0.025,blue:0.09),Color(red:0.035,green:0.02,blue:0.13),Color(red:0.08,green:0.035,blue:0.18)],startPoint:.top,endPoint:.bottom)
        Circle().fill(.purple.opacity(0.25)).frame(width:proxy.size.width*0.72).blur(radius:80).offset(x:proxy.size.width*0.18,y:-proxy.size.height*0.22)
        MountainShape(points:[.init(x:0,y:0.63),.init(x:0.15,y:0.50),.init(x:0.28,y:0.58),.init(x:0.43,y:0.38),.init(x:0.57,y:0.54),.init(x:0.73,y:0.44),.init(x:0.86,y:0.56),.init(x:1,y:0.47),.init(x:1,y:1),.init(x:0,y:1)])
        MountainShape(points:[.init(x:0,y:0.78),.init(x:0.18,y:0.64),.init(x:0.34,y:0.72),.init(x:0.53,y:0.57),.init(x:0.70,y:0.70),.init(x:0.86,y:0.61),.init(x:1,y:0.70),.init(x:1,y:1),.init(x:0,y:1)])
        LinearGradient(colors:[.clear,.black.opacity(0.45)],startPoint:.center,endPoint:.bottom)
    }.ignoresSafeArea() } }
}
private struct MountainShape: Shape { let points:[CGPoint]; func path(in rect:CGRect)->Path { var p=Path(); guard let f=points.first else{return p}; p.move(to:.init(x:f.x*rect.width,y:f.y*rect.height)); for i in 1..<points.count { let pt = points[i]; p.addLine(to: .init(x: pt.x * rect.width, y: pt.y * rect.height)) }; p.addLine(to: .init(x: rect.width, y: rect.height)); p.addLine(to: .init(x: 0, y: rect.height)); p.closeSubpath(); return p } }
