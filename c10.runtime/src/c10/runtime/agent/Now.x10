/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

/** A simple implementation of the TCC next A combinator.

*  @author vj
*/
public class Now(a:()=>void) extends BasicAgent {
    public def isQuiescentNow()=alwaysQuiescent();
    public def now() { 
    		a();
    	}
}
