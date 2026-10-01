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
                HStack { Spacer(); Button(page == pages.count - 1 ? "Done" : "Skip") { finish() }.font(.system(size:14,weight:.semibold)).foregroundStyle(.white.opacity(.62)).padding(.horizontal,20).padding(.top,14) }
                Spacer(minLength:30)
                Image("FugaciousMark").resizable().scaledToFit().frame(width:112,height:112).clipShape(RoundedRectangle(cornerRadius:26,style:.continuous)).shadow(color:.purple.opacity(.28),radius:28,y:12).padding(.bottom,30)
                Text(pages[page].0).font(.system(size:42,weight:.bold,design:.rounded)).foregroundStyle(.white)
                Text(pages[page].1).font(.system(size:20,weight:.medium,design:.rounded)).foregroundStyle(.white.opacity(.82)).multilineTextAlignment(.center).lineSpacing(5).padding(.top,14)
                Text(pages[page].2).font(.system(size:14,design:.rounded)).foregroundStyle(.white.opacity(.45)).multilineTextAlignment(.center).padding(.horizontal,42).padding(.top,16)
                Spacer()
                HStack(spacing:7) { ForEach(0..<pages.count,id:\.self) { i in Capsule().fill(i == page ? .white : .white.opacity(.22)).frame(width:i == page ? 22 : 7,height:7) } }.padding(.bottom,22)
                Button { if page < pages.count - 1 { withAnimation(.easeInOut(duration:.35)) { page += 1 } } else { finish() } } label: { Text(page == pages.count - 1 ? "Enter Fugacious" : "Continue").font(.system(size:16,weight:.bold,design:.rounded)).foregroundStyle(.black).frame(maxWidth:.infinity).frame(height:56).background(.white).clipShape(RoundedRectangle(cornerRadius:18,style:.continuous)) }.buttonStyle(.plain).padding(.horizontal,24).padding(.bottom,18)
            }
        }.preferredColorScheme(.dark)
    }
    private func finish() { withAnimation(.easeInOut(duration:.3)) { hasCompletedOnboarding = true } }
}
private struct OnboardingBackdrop: View {
    var body: some View { GeometryReader { proxy in ZStack {
        LinearGradient(colors:[Color(red:.015,green:.025,blue:.09),Color(red:.035,green:.02,blue:.13),Color(red:.08,green:.035,blue:.18)],startPoint:.top,endPoint:.bottom)
        Circle().fill(.purple.opacity(.25)).frame(width:proxy.size.width*.72).blur(radius:80).offset(x:proxy.size.width*.18,y:-proxy.size.height*.22)
        MountainShape(points:[.init(x:0,y:.63),.init(x:.15,y:.50),.init(x:.28,y:.58),.init(x:.43,y:.38),.init(x:.57,y:.54),.init(x:.73,y:.44),.init(x:.86,y:.56),.init(x:1,y:.47),.init(x:1,y:1),.init(x:0,y:1)]).fill(LinearGradient(colors:[.black.opacity(.78),Color(red:.02,green:.025,blue:.07)],startPoint:.top,endPoint:.bottom))
        MountainShape(points:[.init(x:0,y:.78),.init(x:.18,y:.64),.init(x:.34,y:.72),.init(x:.53,y:.57),.init(x:.70,y:.70),.init(x:.86,y:.61),.init(x:1,y:.70),.init(x:1,y:1),.init(x:0,y:1)]).fill(.black.opacity(.82))
        LinearGradient(colors:[.clear,.black.opacity(.45)],startPoint:.center,endPoint:.bottom)
    }.ignoresSafeArea() } }
}
private struct MountainShape: Shape { let points:[CGPoint]; func path(in rect:CGRect)->Path { var p=Path(); guard let f=points.first else{return p}; p.move(to:.init(x:f.x*rect.width,y:f.y*rect.height)); for q in points.dropFirst(){p.addLine(to:.init(x:q.x*rect.width,y:q.y*rect.height))}; p.closeSubpath(); return p } }
