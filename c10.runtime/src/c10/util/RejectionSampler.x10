package c10.util;

import c10.lang.*;
import c10.lang.Int;
import c10.lang.Double;
import c10.runtime.herbrand.Vat.InitCall;
import c10.runtime.herbrand.FailureException;
import c10.lang.probability.ProbabilisticValue;
import x10.util.HashMap;
import x10.util.ArrayList;

public class RejectionSampler[T](N:XLong){T haszero, T <: x10.lang.Comparable[T]}
//implements C10Driver[T] 

{
	static val logger=Herbrand.logger;
	def addEntry(map:HashMap[Atom[T],XDouble],t:Atom[T], p:XDouble) {
		map.put(t, p+map.getOrElse(t,0D));
		}
	public def run(args: XRail[String],  agentMaker:()=>InitCall[T]) {
		run(args, (Herbrand[T])=>{}, agentMaker);
	}
	public def run(args: XRail[String], binder:(Herbrand[T])=>void, agentMaker:()=>InitCall[T]) {
		val samples = new XRail[Atom[T]](N, null as Atom[T]);
		var count: XInt = 0n;
		for (i in 0..(N-1)) {
			val agent=agentMaker();		
			agent.renew();
			try {			
				val driver = new CCDriver[T]();
				driver.run(args, agent,true); // now run to get a sample
				if (driver.failed) throw new FailureException();
				count++;
				samples(i) = agent.getPromise().getValue();
				//Console.OUT.println("Sample " + i + " value :"  + samples(i));
			} catch (z:Exception) { // check for Abort.
				//Console.OUT.println("Sample " + i + " aborted." );
				//z.printStackTrace();
				samples(i)=null; // null out the result
			} catch (z:Error) {
				Console.OUT.println("Sample " + i + " aborted." );
				z.printStackTrace();
			} 
		}
	 
		if (count ==0n) {
			//Console.OUT.println("No sample succeeded!");
			return;
		}
		val results = new HashMap[Atom[T],XDouble]();
		outer: for (i in 0..(N-1)) {
			if (samples(i)==null) continue;
			inner: for (j in 0..(i-1)) 
				if (samples(i).isoEquals(samples(j))) {
					if (logger.isTraceEnabled()) {
						logger.trace("samples(i)=" + samples(i) + "isoEquals sample j=" + samples(j));
					}
					addEntry(results, samples(j), 1.0D/count);
					continue outer;
				} else {
					if (logger.isTraceEnabled()) {
						logger.trace("samples(i)=" + samples(i) + " does not isoEqual sample j=" + samples(j));
					}
				}
				addEntry(results, samples(i), 1.0D/count);
			}
		val a = new ArrayList[x10.util.Map.Entry[Atom[T],XDouble]]();
		for (e in results.entries()) {
			a.add(e);
			//Console.OUT.print(String.format("%d: %.3f%n", [e.getKey()(), e.getValue()]));
		}
		a.sort((x:x10.util.Map.Entry[Atom[T],XDouble],y:x10.util.Map.Entry[Atom[T],XDouble])=>
		x.getKey().getValue().compareTo(y.getKey().getValue()));
		for (e in a) {
			Console.OUT.print(String.format("%d: %.3f%n", [e.getKey()(), e.getValue()]));
		}
		Console.OUT.println(String.format("%d of %d samples succeeded.", [count, N]));
		
	}
	static def printExceptions(z:MultipleExceptions) {
		for (e in z.exceptions) {
			if (e instanceof MultipleExceptions) printExceptions(e as MultipleExceptions);
			else Console.OUT.print(e + " ");
		}
	}
	
}