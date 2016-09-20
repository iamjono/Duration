# Duration
A simple Swift 3 package for measuring and reporting the time taken for operations. It is derived from [a version for Playgrounds](http://www.swift-studies.com/blog/2015/5/21/performance-testing-in-xcode-playgrounds) that I blogged about some time ago, but kept needing to use in various projects. 

Note the original Swift repo can be found here:
[https://github.com/SwiftStudies/Duration](https://github.com/SwiftStudies/Duration)

## This Fork

This fork is intended as a server side utility. 

* It is Swift 3.0 GM and Swift Package Manager (SPM) ready.

## License 
Duration is distributed under the Apache 2.0 license

###Requirements

- Swift version 3.0

## Installation

### Install via Swift Package Manager

* Add the following to your `Package.swift` file:

``` swift
.Package(
    url: "https://github.com/iamjono/Duration.git", 
    majorVersion: 1, minor: 0
    ),
```

Then, regenerate your Xcode project:

```
swift package generate-xcodeproj
```


## Usage

Duration supports iOS, OS X, tvOS, and Linux.

### Simple Measurements

There are two methods for simple timing measurements. You can insert calls before and after the section of code you wish to measure, for example

	Duration.startMeasurement("Tough Math")
	
	yourToughMathStuff()
	
	Duration.stopMeasurement()
	
Or you can use a block

	Duration.measure("Tough Math"){
		yourToughMathStuff()
	}
	
Or even

	Duration.measure("Tough Math", block: yourToughMathStuff)
	
In all cases (by default) you will get the output (assuming it took 243 milliseconds)

	Tough Math took: 243ms
	
If measurements are nested, they will be appropriately indented in the output, for example if `yourToughMath()` made a measurement of part of its code you would see

	Measuring Tough Math:
		Part 1 took: 100ms
		Part 2 took: 143ms
	Tough Math took: 243ms
	
### Understanding Performance Deviations

In order to better understand how your code is impacted by other things the system is doing you can get average times and standard deviations for block based measurements by supplying a number of iterations for the block, so

	Duration.measure("Tough Math", iterations: 10, forBlock:myToughMath)
	
Would run the block 10 times, taking and reporting the 10  individual measurements and then the average time taken for the block, together with the standard deviation

	Measuring Tough Math
		Iteration 1 took: 243ms
		Iteration 2 took: 242ms
		...
		Iteration 10 took: 243ms
	Tough Math Average: 243ms
	Tough Math STD Dev.: 1ms
	
### Stopping Report Generation

Because you may want to stop reporting of measurements in release builds, you can set the `logStyle` variable in order to control the logging behavior

	Duration.logStyle = .None
	
Will disable measurement logging. In the future I will extend this library to support logging to a data-structure for subsequent analysis, but at this point there are two valid values `.None` and `.Print` 

If you are using Duration within a Package of your own that you are distributing, rather than just over-writing the log style, you can push your desired style, then pop it to restore it to what a consuming package would want. For example

	public func myMethod(){
		//Because this is a release of your package
		//don't log measurements
		pushLogStyle(.None)
		
		// Do stuff that is instrumented
		
		//Restore the logging style to whatever it was
		//before
		popLogStyle()
	}

# Reporting Issues
Please report issues using GitHub's standard system
