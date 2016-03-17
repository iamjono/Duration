//    Copyright 2016 Swift Studies
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

import Foundation

public typealias MeasuredBlock = ()->Void

private var depth = 0

private var depthIndent : String {
    return String(count: depth, repeatedValue: "\t" as Character)
}

/// Define different styles of reporting
public enum MeasurementLogStyle{
    /// Don't measure anything
    case None
    
    /// Print the results of measurements
    case Print
}

public class Duration{
    private static var timingStack = [(startTime:Double,name:String,reported:Bool)]()


    /// Set to control how measurements are reported
    public static var logStyle = MeasurementLogStyle.Print

    ///
    /// Call before code you wish to track performance of, multiple measurements can be nested
    ///
    public static func startMeasurement(name:String){
        if logStyle != .None &&  depth > 0 {
            let containingMeasurement = timingStack.removeLast()
            if !containingMeasurement.reported && logStyle == .Print{
                print("Measuring \(containingMeasurement.name):")
            }
            timingStack.append((containingMeasurement.startTime,containingMeasurement.name,true))
        }
        timingStack.append((NSDate.timeIntervalSinceReferenceDate(),name,false))
        depth += 1
    }
    
    ///
    /// Stops measuring (and reports if a name of the measurement was originally supplied)
    ///
    public static func stopMeasurement()->Double{
        let endTime = NSDate.timeIntervalSinceReferenceDate()
        precondition(depth > 0, "Attempt to stop a measurement when none has been started")
        
        let beginning = timingStack.removeLast()
        
        depth -= 1
        
        let took = endTime - beginning.startTime
        
        if logStyle == .Print {
            print("\(depthIndent)\(beginning.name) took: \(took.milliSeconds)")
        }
        
        return took
    }
    
    ///
    ///  Calls a particular block mesuring the time taken to complete the block.
    ///  If a name is supplied the time take for each iteration will be reported
    ///
    public static func measure(name:String, block: MeasuredBlock)->Double{
        startMeasurement(name)
        block()
        return stopMeasurement()
    }
    
    ///
    /// Calls a particular block the specified number of times, returning the average
    /// number of seconds it took to complete the code. If a name is supplied the time
    /// take for each iteration will be reported
    ///
    public static func measure(name:String,iterations:Int = 10,forBlock block:MeasuredBlock)->Double{
        precondition(iterations > 0, "Iterations must be a positive integer")
        
        var total : Double = 0
        var samples = [Double]()
        
        if logStyle == .Print {
            print("\(depthIndent)Measuring \(name)")
        }
        
        for i in 0..<iterations{
            let took = measure("Iteration \(i+1)",block: block)
            
            samples.append(took)
            
            total += took
        }
        
        let mean = total / Double(iterations)
        
        if logStyle == .Print {
            
            var deviation = 0.0
            
            for result in samples {
                
                let difference = result - mean
                
                deviation += difference*difference
            }
            
            let variance = deviation / Double(iterations)
            
            print("\(depthIndent)\(name) Average", mean.milliSeconds)
            print("\(depthIndent)\(name) STD Dev.", variance.milliSeconds)
        }
        
        return mean
    }
}

private extension Double{
    var milliSeconds : String {
        return String(format: "%03.2fms", self*1000)
    }
    
}

