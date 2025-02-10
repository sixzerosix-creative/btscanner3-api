import SwiftUI

struct ScanCardView: View {
    @State private var isShowingCamera = false
    @State private var scannedImage: UIImage? = nil
    @State private var navigateToResult = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Scan a Basketball Card")
                    .font(.title)
                    .padding()

                Button(action: {
                    isShowingCamera = true
                }) {
                    Text("Open Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $isShowingCamera) {
                    ManualCameraView(scannedImage: $scannedImage, navigateToResult: $navigateToResult)
                }

                // ✅ Fixed: Changed `capturedImage` to `scannedImage`
                NavigationLink(
                    destination: ScanResultView(scannedImage: scannedImage ?? UIImage(named: "placeholder")!),
                    isActive: $navigateToResult
                ) {
                    EmptyView()
                }
            }
            .navigationBarTitle("Scan Card", displayMode: .inline)
        }
    }
}
