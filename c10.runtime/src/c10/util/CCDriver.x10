package c10.util;

import c10.lang.*;
import c10.lang.Rail;
import x10.util.logging.*;
import c10.runtime.herbrand.Teller;
import c10.runtime.agent.Agent;
import c10.runtime.herbrand.Vat;
import c10.runtime.herbrand.Vat.InitCall;

/** A driver that runs the vat for only one time instant, then aborts.
 * @author vj
 */
public class CCDriver[T]{T haszero} implements C10Driver[T] {
	var failed:XBoolean=false;
	public static def processArgs( args:XRail[String]):XRail[String] {
		if (args.size > 0) {
			for (i in 0..(args.size-1)) {
				if (args(i).equals("-d")) {
					// Promise.setPriority(Priority.DEBUG);
					//LogFactory.getLog("c10").setLevel(Level.FINE);
					args(i)="";
				}		
			}
		}
		return args;
	}
	public def run(args: XRail[String],  agent:InitCall[T]) {
		run(args,  agent, false);
	}
	public def run(args: XRail[String],  agent:InitCall[T], silent:XBoolean) {
		if (! silent) Console.OUT.println("C10: starting...");
		val arg1 = processArgs( args );
		java.lang.System.setProperty("org.apache.commons.logging.simplelog.defaultlog","debug");
		java.lang.System.setProperty("log4j.rootCategory","DEBUG");
		try {
			val root = agent.creator()(0n);
			val vat = Vat.makeVat(agent);
			finish {
				async vat.runOnce();
				vat.getTeller().equate( root);
			}
			failed = vat.failed();
			//Console.OUT.println("CCDriver.run failed?" + failed);
			//Console.OUT.println("|- " + agent.varName() + "=" + root);
		} catch (z:Exception) {
			
			//Console.OUT.println("CCDriver.run. Caught " + z);
			z.printStackTrace();
			throw z;
		}
		if (! silent) Console.OUT.println("C10: done.");
	}
}
