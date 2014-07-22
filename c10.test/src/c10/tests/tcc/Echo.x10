/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/
package c10.tests.tcc;

import c10.lang.*;
import c10.lang.Int;
import c10.lang.Rail;
import c10.runtime.herbrand.*;
import c10.util.ConsoleDriver;
import c10.runtime.agent.*;

/** A simple TCC test. Prints out at each time instant the term passed
 * in from the outside world to the vat.
 * @author vj
 */
public class Echo extends Vat.BasicInitCall[XRail[String]] {
	public def this() {super((XInt)=>new Rail[String]());}
    public def getAgent() =  new Always(new BasicAgent() {
    	var i:x10.lang.Int=0n;
		public def now() {
		    p.print( Console.OUT );
		    Console.OUT.println("i=" + i);
		}});

    public static def main(args:x10.lang.Rail[String]) {
    	new ConsoleDriver().run(args,  new Echo());
    }
}
