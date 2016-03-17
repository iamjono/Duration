# Duration
A simple Swift package for measuring and reporting the time taken for operations

## Usage

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

