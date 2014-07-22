/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

import c10.lang.Boolean;

/* An implementation of the always A TCC agent. This implementation
 * optimizes next so that an extra agent is not produced in case A's
 * execution does not result in any activity in a subsequent time
 * instant.

 * @author vj
 */
public 
    class Always extends BasicAgent {
	/*filled*/ var a:Agent;
	public def this(a:Agent) {this.a = a;}
	public def now() { a.now();}
	public def next():Agent {
	    val aNext=(a.copy() as Agent).next();
	    return (aNext.equals(Agent.IDLE))? this: new Par(this, aNext);
	}
	/* This may be quiescent now.  Depends on the contained agent.
	 */
	public def isQuiescentNow():Boolean= a.isQuiescentNow();
	public def toString()= "<" + this.typeName() + " " + a.toString()+ ">";
}
