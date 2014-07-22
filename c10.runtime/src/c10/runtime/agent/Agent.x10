/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;

import c10.runtime.herbrand.*;
import c10.runtime.herbrand.Quiescent;
/* The basic interface implemented by Agents. Each agent must be able
 * to execute at the current time instant, and also determine the
 * Agent to be executed at the next time instant. In order to support
 * the ClockDo combinator, each Agent should also be able to specify
 * whether it is quiescent in the current time instant.

 * <p> Note that an invocation of next may return the same agent, with
 * its internals modified. That is, there is no guarantee that
 * execution of this agent at a current time instant will not modify
 * this agent internally so that in the next time instant it behaves
 * as the successor of itself.
 * @author vj
*/

public interface Agent extends Quiescent {
	val IDLE:Agent = new BasicAgent() {public def toString()="Agent.IDLE";};
	def now():void;
	def next():Agent;
	def copy():Agent;
	
}
