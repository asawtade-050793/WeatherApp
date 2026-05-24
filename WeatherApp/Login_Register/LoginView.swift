//
//  Untitled.swift
//  WeatherApp
//
//  Created by Akshay Awtade on 23/05/26.
//

import SwiftUI
import SwiftData

struct LoginView:View {
    var body: some View {
        VStack{
            ZStack(alignment: .top) {
                Image("background_night").resizable().frame(height: 350).offset(y:-65)
                VStack{
                    Spacer()
                    Text("Weather APP").foregroundStyle(.black).font(.title)
                    Text("Version: 1.0.0")
                }
            }
            
            
        }
    }
}


#Preview {
    LoginView()
}
