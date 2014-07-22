/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.herbrand;

import x10.util.Stack;
import x10.util.logging.*;
import c10.lang.Herbrand;

/** A port is the entry point for foreign data, and hence the external
 * clock, into a vat. Each vat has at most one port associated with
 * it. Each port has an associated teller which can be accessed as a
 * public final variable.

 * <p> TBD: Perhaps some exception should be thrown if an attempt is made
 * to send a message to a Port, and its associated Vat has aborted.

 * @author vj
 */
public class  Port[T] {
    public static val logger=LogFactory.getLog("c10.runtime");	
   
    static private class MyTeller[T] implements Teller[T] {
    	val items = new Stack[Herbrand[T]]();
    	public def equate(o: Herbrand[T]) {
    		atomic items.push(o);
    	}
    }
    public val teller = new MyTeller[T]();
    public def get() {
    	when (! teller.items.isEmpty()) return teller.items.pop();
    }
}
