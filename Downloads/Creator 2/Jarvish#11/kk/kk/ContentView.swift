import SwiftUI

struct ContentView: View {
    @State private var Java = ""
    @State private var python = ""
    @State private var C = ""
    @State private var totalmarks:Double = 0.0
    @State private var percentage:Double = 0.0
    @State private var grade:String = ""
    var body: some View {
        ZStack {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 90))
                .foregroundStyle(.blue.opacity(0.11))
                .offset(x:130, y: -300)
            Image(systemName: "book.fill")
                .font(.system(size: 99))
                .foregroundStyle(.purple.opacity(0.11))
                .offset(x:-130,y:-150)
            Image(systemName: "pencil.and.ruler.fill")
                .font(.system(size: 99))
                .foregroundStyle(.purple.opacity(0.11))
                .offset(x:140,y:100)
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 99))
                .foregroundStyle(.green.opacity(0.11))
                .offset(x:-140,y:250)
            Image(systemName: "doc.text.fill")
                .font(.system(size: 99))
                .foregroundStyle(.green.opacity(0.11))
                .offset(x:100,y:320)
            VStack(spacing: 20){
                Text("Student grade calculator")
                    .font(.system(size: 27))
                    .fontWeight(.semibold)
                    .foregroundStyle(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .leading, endPoint: .trailing))
                HStack{
                    TextField("Java Marks",text: $Java)
                        .padding()
                    Image("java")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding()
                        .keyboardType(.numberPad )
                }
                .frame(width: 350,height: 55)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .shadow(radius: 9)
                HStack{
                    TextField("Python Marks",text: $python)
                        .padding()
                    Image("python")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding()
                        .keyboardType(.numberPad )
                }
                .frame(width: 350,height: 55)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .shadow(radius: 9)
                HStack{
                    TextField("C Marks",text: $C)
                        .padding()
                    Image("C")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .padding()
                        .keyboardType(.numberPad )
                }
                .frame(width: 350,height: 55)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                .shadow(radius: 9)
                
                Button{
                    //action
                    let j = Double(Java) ?? 0.0
                    let p = Double(python) ?? 0.0
                    let m = Double(C) ?? 0.0
                    totalmarks = j + p + m
                    percentage = totalmarks/300 * 100
                    
                    
                    
                    if percentage >= 90 {
                        grade = "A+"
                    }
                    else if percentage >= 80
                    {
                        grade = "A"
                    }
                    else if percentage >= 70
                    {
                        grade = "B"
                    }
                    else if percentage >= 60
                    {
                        grade = "C"
                    }
                    else if percentage >= 50
                    {
                        grade = "D"
                    }
                    else {
                        grade = "F"
                    }
                    
                    Java = ""
                    python = ""
                    C  = ""
                    
                }label: {
                    Text("Calculate")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(width: 300,height: 54)
                        .background(LinearGradient(colors: [.orange,.pink,.purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(18)
                        .shadow(radius: 9)
                    
                }
                
                Divider()
                Text("Total Marks:\(Int(totalmarks))/300")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .padding()
                Text("Grade:\(percentage,specifier: "%.2f")")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                
                Text("Grade:\(grade)")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
          }
        }
    }


#Preview {
    ContentView()
}

