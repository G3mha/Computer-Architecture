# ENGR 3410: Miniproject 3

**due March 13, 2025**

In this miniproject, you will use the OSS CAD suite to design a digital circuit to produce a sinudoidal waveform through a 10-bit R-2R ladder digital-to-analog converter (DAC). You will be supplied with a sample project in the iceBlinkPico Github repository as a starting point. Your task in this miniproject is to produce the same waveform as the sample project does using less memory storage for the samples by taking advantage of certain symmetries within one cycle of the sine function.

This miniproject is an individual one. You can discuss design approaches and help each other with learning SystemVerilog and how to use the OSS CAD suite, but each of you must complete all aspects of this assignment in order to learn how to use the tools. In the process, you should learn several aspects of the processes and software tools that you will be using later in the semester to design more complex digital circuits.

## Requirements

Your design must meet the following requirements:

1. Your circuit must produce a sinusiodal voltage waveform at a single frequency through the supplied 10-bit R-2R ladder DAC with 512 10-bit samples per cycle of the waveform.

2. Your circuit should use a look-up table with no more than 128 9-bit samples of the first quarter cycle of a sine wave and compute the sample values for the other three quarters of the cycle by taking advantage of various symmetries within one cycle of the sine function.

3. Your circuit must be specified in one or more SystemVerilog source files.

4. You must provide a SystemVerilog test bench and simulation results using Icarus Verilog (iverilog) showing at least one complete cycle of your circuit's operation.

5. You must provide a measured voltage waveform produced by your circuit using an oscilloscope.

## Deliverables

By the start of class on March 13, you must submit the following items to the course Canvas site:

1. A PDF file containing a brief report explaining the design of your circuit and its operation. You should include a screen grab of a gtkwave plot showing the simulation of the output waveform changing as a function of time in your circuit shown using one of the analog data formats in gtkwave. You should also include a plot showing the output voltage from your circuit as a function of time measured using an oscilloscope.

2. Copies of all of the source files specifying your circuit as well as your test bench. You may provide the URL of a Github repo or a shared folder containing your source files.
