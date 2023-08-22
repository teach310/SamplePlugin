//
//  BLEClientView.swift
//  SamplePluginApp
//
//  Created by Taichi Sato on 2023/08/22.
//

import SwiftUI
import SamplePlugin

struct BLEClientView: View {
    @State var bleSample: BLESample?
    
    var body: some View {
        VStack {
            Text("BLEClient")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
            
            
            Button(action: {
                if bleSample?.isConnected() ?? false {
                    bleSample?.writeData()
                } else {
                    bleSample?.scan()
                }
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
            if bleSample == nil {
                bleSample = BLESample()
            }
        }
    }
}

struct BLEClientView_Previews: PreviewProvider {
    static var previews: some View {
        BLEClientView()
    }
}
