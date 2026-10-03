func marks(maths: Int, sci: Int, eng: Int)->Int {
    let average = maths + sci + eng / 3
    return average
}

print("your average is: \(marks(maths: 60, sci: 70, eng: 65))")
print("your average is: \(marks(maths: 70, sci: 70, eng: 65))")
print("your average is: \(marks(maths: 55, sci: 50, eng: 75))")
