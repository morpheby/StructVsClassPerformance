//
//  StructvsClassPerformance.swift
//
//  MIT License
//  Copyright (c) 2018 Ilya Mikhaltsou
//  Copyright (c) 2018 Gokhan Topcu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import Darwin

/// xcrun -sdk macosx swiftc -O -whole-module-optimization StructvsClassPerformance.swift

typealias MachTime = UInt64

enum MachTimeUtils {

    /// - Returns: Current mach time of execution
    static func now() -> MachTime {
        return mach_absolute_time()
    }

    /// Finds time difference between two mach time
    ///
    /// - Parameters:
    ///   - start: Starting mach time
    ///   - end: Ending mach time
    /// - Returns: Time difference in milliseconds
    static func milliSecondsBetween(start: MachTime, end: MachTime) -> MachTime {
        return MachTime(convertToNanoSeconds(end - start) / 1e6)
    }

    /// Converts given mach time to nanoseconds
    ///
    /// - Parameter time: Mach time to convert
    /// - Returns: Time in naneseconds
    static func convertToNanoSeconds(_ time: MachTime) -> Double {
        var timeBase = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&timeBase)
        return Double(time) * Double(timeBase.numer) / Double(timeBase.denom)
    }
}

struct DummyStruct
{
    var flag: Bool
    var count: Int
    init(flag: Bool, count: Int)
    {
        self.flag = flag
        self.count = count
    }
}

class ContainerClass
{
    var dummy0: DummyStruct
    var dummy1: DummyStruct
    var dummy2: DummyStruct
    var dummy3: DummyStruct
    var dummy4: DummyStruct
    var dummy5: DummyStruct
    var dummy6: DummyStruct
    var dummy7: DummyStruct
    var dummy8: DummyStruct
    var dummy9: DummyStruct

    init(dummy0: DummyStruct,
         dummy1: DummyStruct,
         dummy2: DummyStruct,
         dummy3: DummyStruct,
         dummy4: DummyStruct,
         dummy5: DummyStruct,
         dummy6: DummyStruct,
         dummy7: DummyStruct,
         dummy8: DummyStruct,
         dummy9: DummyStruct)
    {
        self.dummy0 = dummy0
        self.dummy1 = dummy1
        self.dummy2 = dummy2
        self.dummy3 = dummy3
        self.dummy4 = dummy4
        self.dummy5 = dummy5
        self.dummy6 = dummy6
        self.dummy7 = dummy7
        self.dummy8 = dummy8
        self.dummy9 = dummy9
    }
}

struct ContainerStruct
{
    var dummy0: DummyStruct
    var dummy1: DummyStruct
    var dummy2: DummyStruct
    var dummy3: DummyStruct
    var dummy4: DummyStruct
    var dummy5: DummyStruct
    var dummy6: DummyStruct
    var dummy7: DummyStruct
    var dummy8: DummyStruct
    var dummy9: DummyStruct
}

@inline(never)
func testClass(_ container: ContainerClass) -> Int
{
    // Just call other function to create a new reference to the class
    let value = simpleCalculationForClass(container, &container.dummy3)
    return value
}

@inline(never)
func testStruct(_ container: ContainerStruct) -> Int
{
    // Just call other function to create a new copy of the struct
    let value =  simpleCalculationForStruct(container)
    return value
}

@inline(never)
func simpleCalculationForClass(_ testClass: ContainerClass, _ sp: inout DummyStruct) -> Int
{
    // Make a simple operation
    return (testClass.dummy3.count ^ 0x9e3779b9) >> testClass.dummy9.count
}

@inline(never)
func simpleCalculationForStruct(_ testStruct: ContainerStruct) -> Int
{
    // Make a simple operation
    return (testStruct.dummy3.count ^ 0x9e3779b9) >> testStruct.dummy9.count
}

/// Function to test class performance
@inline(never)
func calculateClassPerformance(with dummies: ContiguousArray<DummyStruct>, iterations: Int64)
{
    // Create a container class instance
    let container = ContainerClass(
        dummy0: dummies[0],
        dummy1: dummies[1],
        dummy2: dummies[2],
        dummy3: dummies[3],
        dummy4: dummies[4],
        dummy5: dummies[5],
        dummy6: dummies[6],
        dummy7: dummies[7],
        dummy8: dummies[8],
        dummy9: dummies[9]
    )

    let startTime = MachTimeUtils.now()
    var result: Int = 0

    for _ in 0..<iterations
    {
        // Create a copy of instance then pass it to the function
        // to create new pointers to the original instance
        let copy = container
        result += testClass(copy)
    }

    let endTime = MachTimeUtils.now()
    let period = MachTimeUtils.milliSecondsBetween(start: startTime, end: endTime)

    print("Class: \(period)")
    print("Result: \(result)")
}

@inline(never)
func calculateStructPerformance(with dummies: ContiguousArray<DummyStruct>, iterations: Int64)
{
    // Create an instance of struct that contains multiple classes
    var container = ContainerStruct(
        dummy0: dummies[0],
        dummy1: dummies[1],
        dummy2: dummies[2],
        dummy3: dummies[3],
        dummy4: dummies[4],
        dummy5: dummies[5],
        dummy6: dummies[6],
        dummy7: dummies[7],
        dummy8: dummies[8],
        dummy9: dummies[9]
    )

    let startTime = MachTimeUtils.now()
    var result: Int = 0

    for _ in 0..<iterations
    {
        // Create a copy of instance then pass it to the function
        // to create new copies of the original instance
        let copy = container
        result += testStruct(copy)
    }

    let endTime = MachTimeUtils.now()
    let period = MachTimeUtils.milliSecondsBetween(start: startTime, end: endTime)

    print("Struct: \(period)")
    print("Result: \(result)")
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// EXECUTION STARS HERE ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/// Iteration count for execution
let testIterationCount: Int64 = 100_000_000

/// Create an array of dummy structs with different data
var dummies = ContiguousArray<DummyStruct>()
for j in 0..<10
{
    let dummy = DummyStruct(flag: j % 2 == 0, count: j)
    dummies.append(dummy)
}

// Test performance for class
calculateClassPerformance(with: dummies, iterations: testIterationCount)

// Test performance for struct
calculateStructPerformance(with: dummies, iterations: testIterationCount)

