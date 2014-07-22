/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

import x10.util.logging.*;

import c10.lang.Herbrand;

/** An implementation of the do A watching c TCC combinator.

* @author vj
*/
public class DoWatching extends BasicAgent {
	public static val logger = LogFactory.getLog("c10.runtime.agent");

	/*filled*/ var a:Agent;
	/*filled*/ var p:Herbrand[Any];
	public def this(a:Agent, p:Herbrand[Any]) {
	    this.a = a;
	    this.p = p;
	}
	public def now(){
	    if ( logger.isDebugEnabled())
		logger.debug( "Executing " + this);

	    a.now();
	    if ( logger.isDebugEnabled())
		logger.debug( "Executing " + this + " done.");
	}
	public def next() {
	    if ( logger.isDebugEnabled()) {
		logger.debug( "Executing " + this);
		logger.debug(" p.known() = "  + p.known());
	    }

	    a = p.known() ? Agent.IDLE 	: a.next();
	    if ( logger.isDebugEnabled()) {
		logger.debug( "Executing " + this+ " done.");
	    }
	    return this;
	}
}
