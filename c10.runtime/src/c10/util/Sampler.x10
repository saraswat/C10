package c10.util;

import c10.lang.XDouble;

public class Sampler {
	
	//TODO: null is not correct
	public static val currentSampler: Cell[Sampler] = new Cell(null as Sampler);
	
	public var currentProbability:XDouble;
		
	public def this(){}
}