/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

import x10.util.logging.*;
import c10.lang.Boolean;
import c10.lang.Abort;

/** A simple implementation of the TCC parallel composition
 * combinator. Treats all its argument agents as if they are running
 * in parallel.
 */
public class Par extends BasicAgent {
        public static val logger =LogFactory.getLog("c10");
	val a:Rail[Agent];
	var aLength:Long;
	public  def this( a:Rail[Agent]) {
	    this.a = a;
	    this.aLength = a.size;
	}
	public def this(a1: Agent, a2:Agent) {this( [a1, a2]);}
	public def this(a1:Agent, a2:Agent, a3:Agent){this( [a1, a2,a3]);}

	/** Execute each of the contained agents at the current time
	 * instant.
	 */
	public def now() throws Abort {
		for (i in 0..(aLength-1)) {
			val agent =a(i);
			if ( logger.isDebugEnabled())
				logger.debug( "Par " + this + "[" + i + "] executing " + agent);
			agent.now();
			if ( logger.isDebugEnabled())
				logger.debug( "Par " + this + "["+i+"] done.");
		}
	}

	/** A Par agent is quiescent now iff each one of its subagents
	    is quiescent now. */
	public def isQuiescentNow(): Boolean {
	    val sc = new Rail[Boolean](a.size+1, (i:Long)=> new Boolean(true));

	    try {
		sc(0).equate( new Boolean(true));
		for (i in 0..(a.size-1)) 
		    a(i).isQuiescentNow().runWhenRealized( ()=> {sc(i).equate(sc(i+1));});
	    } catch (z:Abort) {
		// Cannot occur.
	    }
	    return sc(a.size);

	}
	/** Return the same agent, after updating its internal state
	 * so that each contained agent is replaced by its next agent.
	 */
	public def next():Agent {
	    var i:Long = 0;
	    while (i < aLength) {
		val next = a(i).next();
		if (next.equals(Agent.IDLE)) {
		    a(i) = a(aLength -1);
		    aLength--;
		} else {
		    a(i) = next;
		    i++;
		}
	    }
	    val result = (aLength == 0) ? Agent.IDLE  : (aLength == 1) ? a(0) : this;
	    if ( logger.isDebugEnabled())
		logger.debug( "Par " + this + ".next() returns " + result);

	    return  result;

	}
	public def clone():Par = new Par(new Rail[Agent](a.size, (i:Long)=>a(i).copy()));

	public def toString():String {
	    var result:String = "<" + this.typeName();
	    for (i in 0 .. (a.size-1)) result += a(i);
	    return result + ">";
	}

}
