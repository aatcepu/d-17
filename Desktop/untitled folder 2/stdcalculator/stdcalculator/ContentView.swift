//
//  ContentView.swift
//  stdcalculator
//
//  Created by Student on 28/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var maths:String = ""
    @State private var Physics:String = ""
    @State private var chemistry:String = ""
    @State private var totalmarks:Double = 0.0
    @State private var percentage:Double = 0.0
    @State private var grade:String = ""
    
    var body: some View {
        ZStack{
            Color.orange.opacity(0.50)
                .ignoresSafeArea()
            Image(systemName: "graduationcap.fill")
                .font(.system(size:100))
                .foregroundStyle(.blue.opacity(0.20))
                .offset(x:100 , y:-300)
            Image(systemName: "pencil.and.ruler.fill")
                .font(.system(size:100))
                .foregroundStyle(.blue.opacity(0.20))
                .offset(x:-100 , y:-30)
            Image(systemName: "book.fill")
                .font(.system(size:100))
                .foregroundStyle(.blue.opacity(0.20))
                .offset(x:100 , y:300)
            
            VStack{
                Text("Student Grades Calculator")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .red, .orange,.yellow], startPoint: .leading, endPoint: .trailing)
                    )
                HStack{
                    TextField("Enter maths marks 0-100",text: $maths)
                        .padding()
                    Image(systemName: "sum")
                        .padding()
                        .foregroundStyle(.gray)
                }
                .frame(width: 350, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 15)
                HStack{
                    TextField("Enter physics marks 0-100",text: $maths)
                        .keyboardType(.numberPad)
                        .padding(10)
                    
                    
                        
                        .padding()
                    Image(systemName: "atom")
                        .padding()
                        .foregroundStyle(.gray)
                }
                .frame(width: 350, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 15)
                HStack{
                    TextField("Enter chemistry marks 0-100",text: $maths)
                        .padding()
                    Image(systemName: "flask")
                        .padding()
                        .foregroundStyle(.gray)
                }
                .frame(width: 350, height: 60)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 15)
                Button{
                    var m = Double(maths) ?? 0.0
                    var p = Double(Physics) ?? 0.0
                    var c = Double(chemistry) ?? 0.0
                    
                    totalmarks = m + p + c
                    percentage = (totalmarks/300)*100
                    if percentage >= 90{
                        grade = "A"
                        
                    }
                    else if percentage >= 70{
                        grade = "B"
                    }
                    else if percentage >= 60{
                        grade = "C"
                    }
                    else if percentage >= 50{
                        grade = "D"
                    }
                    else{
                        grade = "F"
                    }
                }label:{
                    Text("Calculator")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .frame(width: 300, height: 60)
                        .background(.black)
                        .cornerRadius(15)
                }
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(Color(.orange.opacity(0.0)))
                
                Text("Totalmarks\(totalmarks,specifier: "%.2f")/ 300")
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
                Text("Percentage\(percentage,specifier: "%.2f")%")
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
                Text("Grade\(grade)")
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
                
                    
                
            }.frame(width: 380, height: 450)
                .background(.fill)
                .cornerRadius(20)
            
        }
        
            
            
    }
}

#Preview {
    ContentView()
}
