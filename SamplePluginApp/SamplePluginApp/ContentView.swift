//
//  ContentView.swift
//  SamplePluginApp
//
//  Created by Taichi Sato on 2023/06/06.
//

import SwiftUI
import SamplePlugin

struct ContentView: View {
    @State var number = 0
    @State var bleSample = BLESample()
    
    var body: some View {
        VStack {
            Text("\(number)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)


            Button(action: {
                if bleSample.isConnected() {
                    bleSample.writeData()
                } else {
                    bleSample.scan()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
