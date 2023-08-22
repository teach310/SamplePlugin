//
//  ContentView.swift
//  SamplePluginApp
//
//  Created by Taichi Sato on 2023/06/06.
//

import SwiftUI


struct ContentView: View {
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("BLESample")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                
                NavigationLink(destination: BLEClientView()) {
                    Text("BLEClient")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: BLEServerView()) {
                    Text("BLEServer")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
