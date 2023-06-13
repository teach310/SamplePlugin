//
//  ContentView.swift
//  SamplePluginApp
//
//  Created by Taichi Sato on 2023/06/06.
//

import SwiftUI
import SamplePlugin

struct ContentView: View {
    @State var steps = 0
    
    var body: some View {
        VStack {
            Text("\(steps)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)

            Button(action: {
                HealthKitData().getStepsToday { steps in
                    self.steps = steps
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
            HealthKitData().authorize { success in
                print("authorize: \(success)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
