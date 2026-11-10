import SwiftUI

struct RidgeBackdrop<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground")
                    .overlay {
                        Image("BgCold")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.38)
                    }
                    .clipped()
                    .ignoresSafeArea()
            }
    }
}
