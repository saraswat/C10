package c10.util;

import c10.lang.*;
import c10.lang.Rail;
import x10.util.logging.*;
import c10.runtime.herbrand.Teller;
import c10.runtime.herbrand.Vat.InitCall;
import c10.runtime.herbrand.Vat;

/** A simple Driver for a TCC program. Reads lines of text from the console
 * and sends them on the given teller for the vat.
 * @author vj
 */
public class ConsoleDriver implements C10Driver[XRail[String]] {
	
	public def run(args: XRail[String], 
			agent:InitCall[XRail[String]]) {
		Console.OUT.println("C10: starting...");
		val arg1 = CCDriver.processArgs( args );
		java.lang.System.setProperty("org.apache.commons.logging.simplelog.defaultlog","debug");
		java.lang.System.setProperty("log4j.rootCategory","DEBUG");
		try {
			finish {
				val vat = Vat.makeVat(agent);
				async vat.run();
				val teller = vat.getTeller();
				teller.equate( new Rail[String](arg1));
				val reader = Console.IN; //new BufferedReader( new InputStreamReader( Console.IN ));
				var i:x10.lang.Int=0n;
				do {
					Console.OUT.println("Reading...:");
				
					val line:String = reader.readLine(); 
					Console.OUT.println("Read |" + line + "|");
					//if (i > 50) break;
					// Need to ensure that this happens only when the vat is quiescent?
					teller.equate( new Rail[String]([line as String]));
					
				} while ( true );
			}
		} catch (z:Exception) {
			z.printStackTrace();
		}
		Console.OUT.println("C10: done.");
	}
	
}
