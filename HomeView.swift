import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("BTCScanner")
                .font(.largeTitle)
                .bold()
            
            NavigationLink(destination: ScanCardView()) {
                Text("Scan a Card")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: CollectionView()) {
                Text("View Collection")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
