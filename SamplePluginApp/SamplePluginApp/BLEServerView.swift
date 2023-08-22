//
//  BLEServerView.swift
//  SamplePluginApp
//
//  Created by Taichi Sato on 2023/08/22.
//

import SwiftUI
import SamplePlugin

struct BLEServerView: View {
    @State var bleServer: BLEServerSample?
    
    var body: some View {
        VStack {
            Text("BLEServer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            
            
            Button(action: {
                bleServer?.onClick()
            }) {
                Text("Tap me!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            if bleServer == nil {
                bleServer = BLEServerSample()
            }
        }
    }
}

struct BLEServerView_Previews: PreviewProvider {
    static var previews: some View {
        BLEServerView()
    }
}
