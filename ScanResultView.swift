import SwiftUI
import Alamofire

struct ScanResultView: View {
    var scannedImage: UIImage
    @State private var playerName: String = "Loading..."
    @State private var teamName: String = "Loading..."
    @State private var cardSet: String = "Loading..."
    @State private var cardNumber: String = "Loading..."
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isAddingToCollection = false

    var body: some View {
        VStack {
            Text("Scan Result")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Image(uiImage: scannedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 350)
                .cornerRadius(10)
                .shadow(radius: 5)

            if isLoading {
                ProgressView("Processing...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("🏀 Player: \(playerName)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("🏆 Team: \(teamName)")
                        .font(.title3)
                    Text("📅 Set: \(cardSet)")
                        .font(.title3)
                    Text("🔢 Card #: \(cardNumber)")
                        .font(.title3)
                }
                .padding()
            }

            Spacer()

            Button(action: {
                addToCollection()
            }) {
                Text(isAddingToCollection ? "Adding..." : "Add to Collection")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isAddingToCollection)

            Button(action: {
                processScan()
            }) {
                Text("Retry Scan")
                    .font(.headline)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            processScan()
        }
    }

    private func processScan() {
        isLoading = true
        errorMessage = nil

        // Convert the scanned image to a JPEG and upload it to a local server
        guard let imageData = scannedImage.jpegData(compressionQuality: 0.8) else {
            self.errorMessage = "Failed to process image"
            self.isLoading = false
            return
        }

        let apiUrl = "http://127.0.0.1:5000/process_scan"  // 🔹 Use Local API for testing
        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        // 🔹 Upload image to the local API
        AF.upload(multipartFormData: { formData in
            formData.append(imageData, withName: "image", fileName: "scan.jpg", mimeType: "image/jpeg")
        }, to: apiUrl, headers: headers)
        .responseJSON { response in
            DispatchQueue.main.async {
                self.isLoading = false

                switch response.result {
                case .success(let value):
                    if let json = value as? [String: String] {
                        self.playerName = json["player_name"] ?? "Unknown Player"
                        self.teamName = json["team_name"] ?? "Unknown Team"
                        self.cardSet = json["set_name"] ?? "Unknown Set"
                        self.cardNumber = json["card_number"] ?? "Unknown Number"
                    } else {
                        self.errorMessage = "Invalid response format"
                    }
                case .failure(let error):
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func addToCollection() {
        isAddingToCollection = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAddingToCollection = false
            print("✅ Card added to collection!")
        }
    }
}
