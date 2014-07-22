/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/
package c10.tests.cc;

import c10.lang.*;
import c10.lang.Int;
import c10.lang.Rail;
import c10.runtime.herbrand.*;
import c10.util.CCDriver;
import c10.runtime.agent.*;

/** A simple cc "Hello World". Prints out the string passed in from the command
 * line.
 * @author vj
 */
public class Echo extends Vat.BasicInitCall[XRail[String]] {
	public def this() {super((XInt)=>new Rail[String]());}
	public def getAgent() =  new Now(()=>{p.print( Console.OUT );});
    
    public static def main(args:XRail[String]) {
    	new CCDriver[XRail[String]]().run(args, new Echo());
    }
}
