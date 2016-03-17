import Foundation

public typealias MeasuredBlock = ()->Void

private var depth = 0

private var depthIndent : String {
    return String(count: depth, repeatedValue: "\t" as Character)
}

private var timingStack = [(startTime:Double,name:String?,reported:Bool)]()

/// Define different styles of reporting
public enum MeasurementLogStyle{
    /// Don't measure anything
    case None
    
    /// Print the results of measurements
    case Print
}

/// Set to control how measurements are reported
public var measurementLogStyle = MeasurementLogStyle.Print

///
/// Call before code you wish to track performance of, multiple measurements can be nested
///
public func startMeasurement(name:String? = nil){
    if measurementLogStyle != .None &&  depth > 0 {
        let containingMeasurement = timingStack.removeLast()
        if let name = containingMeasurement.name where !containingMeasurement.reported{
            print("Measuring \(name):")
        }
        timingStack.append((containingMeasurement.startTime,containingMeasurement.name,true))
    }
    timingStack.append((NSDate.timeIntervalSinceReferenceDate(),name,false))
    depth += 1
}

///
/// Stops measuring (and reports if a name of the measurement was originally supplied)
///
public func stopMeasurement()->Double{
    let endTime = NSDate.timeIntervalSinceReferenceDate()
    precondition(depth > 0, "Attempt to stop a measurement when none has been started")
    
    let beginning = timingStack.removeLast()
    
    depth -= 1
    
    let took = endTime - beginning.startTime
    
    if let name = beginning.name where measurementLogStyle == .Print {
        print("\(depthIndent)\(name) took: \(took.milliSeconds)")
    }
    
    return took
}

///
///  Calls a particular block mesuring the time taken to complete the block.
///  If a name is supplied the time take for each iteration will be reported
///
public func measure(name:String? = nil, block: MeasuredBlock)->Double{
    startMeasurement(name)
    block()
    return stopMeasurement()
}

///
/// Calls a particular block the specified number of times, returning the average
/// number of seconds it took to complete the code. If a name is supplied the time
/// take for each iteration will be reported
///
public func measure(name:String? = nil,iterations:Int = 10,forBlock block:MeasuredBlock)->Double{
    precondition(iterations > 0, "Iterations must be a positive integer")
    
    var total : Double = 0
    var samples = [Double]()
    
    if let name = name {
        print("\(depthIndent)Measuring \(name)")
    }
    
    for _ in 0..<iterations{
        let took = measure(name,block: block)
        
        samples.append(took)
        
        total += took
    }
    
    let mean = total / Double(iterations)

    if let name = name {

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

extension Double{
    var milliSeconds : String {
        return String(format: "%03.2fms", self*1000)
    }
    
}

