/*
 * jcc -- The Java Concurrent Constraint Programming Language
 * Copyright (C) 2003 Vijay A Saraswat
 * Please see ../../CopyRight.txt for the copyright declaration.
 */

package c10.runtime.herbrand;

import x10.util.logging.*;
import c10.lang.Herbrand;
import c10.runtime.agent.*;
import c10.lang.Boolean;
import c10.lang.XBoolean;
import c10.lang.Atom;
import c10.lang.Abort;
import c10.lang.XInt;
import x10.compiler.NoThisAccess;
import x10.compiler.NonEscaping;


public class Vat[T]{T haszero}  {
	public static val logger = LogFactory.getLog("c10.runtime");
	var failed:XBoolean = false;
	public def failed():XBoolean=failed;
	
	/** This interface specifies what a Vat expects the initial object
	 * to do. This object must create an instance p of Promise as a
	 * result of the call to getPromise, and return it. This instance
	 * must not be created when this object is initialized, but when
	 * this method is called. For, the method will be called in the
	 * Vat to which this object is passed, and hence the promise will
	 * be local to the vat in which the object is being
	 * executed. run() must specify what should happen when this
	 * promise is equated to a value. The teller for the vat can be
	 * used to send values to p.
	 */
	
	public static interface InitCall[T]{T haszero} {
		@NonEscaping @NoThisAccess def creator():(XInt)=>Herbrand[T];
		/** Create a fresh variable */
		def renew():void;
		/** Return the associated variable.*/
		def getPromise():Herbrand[T];
		/** Return the agent, this will typically make use of the associated variable.*/
		def getAgent():Agent;
		def varName():String;
		
	}
	
	/** A basic implementation of InitCall that provides the internal
	 * promise (p), and has an IDLE agent.
	 */
	public static abstract class BasicInitCall[T]{T haszero} implements InitCall[T] {
		protected var p:Herbrand[T];
		var i:XInt=0n;
		protected val maker:(i:XInt)=>Herbrand[T];
		public def this(m:(XInt)=>Herbrand[T]) {
			maker=m;
			p = m(i++);
		}
		public def varName():String="result";
		public def creator()=maker;
		public def renew() { p = maker(i++);}
		public def getPromise():Herbrand[T] = p;
		public def getAgent(): Agent = Agent.IDLE;
	}
	val initCall:InitCall[T];
	var port:Port[T];
	var initPromise:Herbrand[T]; // Really do want to make this final.
	var agent:Agent;
	public static val clock = new Clock();
	
	private def this( call:InitCall[T] ) {
		super();
		this.initCall = call;
		this.port = new Port[T]();
	}
	
	public static class Clock {
		/* package protected. */
		var timeStamp:x10.lang.Int = 0n;
		/** non-final public field.. ugh :-( */
		public var currentCP:ChoicePoint = null;
		public var baseCP: ChoicePoint = null;
		public var collectedCP:ChoicePoint = null;
		public def timeStamp()=timeStamp;
		
		/** Bump up the clock, reinitializing global variables. */
		def inc() {
			timeStamp++;
			currentCP = baseCP = collectedCP = null;
			if ( logger.isInfoEnabled())
				logger.info( "The time is " + timeStamp + ".");
			
		}
	}
	
	/** Returns a Teller for a new Vat, running call.
	 * @parameter call -- the code to be run by the new vat.
	 */
	public static def  makeVatTeller( call:InitCall[Rail[String]] ):Teller [Rail[String]]{
		val vat = new Vat( call );
		async vat.run();
		return vat.getTeller();
	}
	public static def  makeVat[T]( call:InitCall[T] ){T haszero}=new Vat( call );
	
	
	/** Obtain the teller associated with the Vat's port.
	 */
	public getTeller():Teller[T] = this.port.teller;
	
	/** Suspend until a message is available on the port. Bind this
	 * message to the internal variable associated with the port. Run
	 * the current agent associated with the port. Once that is done,
	 * determine the next agent associated with the port, bump up the
	 * time instant (so that the current constraint store is dropped),
	 * and repeat. If the currently executing agent throws an Abort
	 * error, then the vat aborts from its loop. Subsequently it will
	 * not respond to any stimulus -- it is well and truly dead.
	 */
	public def  run():void {
		this.initPromise = initCall.getPromise();
		this.agent = initCall.getAgent();
		try {
			while ( true ) {
				// Get the value of the input for the next time
				// instant. This call may suspend.
				val value = port.get();
				
				if ( logger.isDebugEnabled())
					logger.debug( "value =" + value + " agent=" + agent);
				
				// The input to be executed at the next time instant
				// is now available. Provide the value for the input
				// variable. Note that this will cause the variable
				// input to become current, if necessary.
				
				initPromise.equate( value );
				
				try {
					// Run the agent for the current time instant.
					// This may throw an Abort. Aborts are propagated
					// out of the loop and cause the Vat to abort.
					agent.now();
					
					if ( logger.isDebugEnabled())
						logger.debug( "Running choicepoints");
					if (clock.collectedCP != null) clock.collectedCP.run();
				} catch (z:FailureException) {
					if (logger.isInfoEnabled())
						logger.info("The vat " + this + 
								" became inconsistent at " + 
								                           clock.timeStamp+".");
					failed=true;
				}
				
				// Compute the next agent.
				// Schedule all the "next" tasks now.
				if ( logger.isDebugEnabled()) logger.debug( "Computing nexts.");
				agent = agent.next();
				
				// Bump up the current time-step.
				clock.inc();
			}
		} catch (z:Abort) {
			//z.printStackTrace();
			if (logger.isInfoEnabled())
				logger.info("The Vat " + this + " has aborted at " + clock.timeStamp + ".");
			throw z;
		}
	}
	public def runOnce():void {
		this.initPromise = initCall.getPromise();
		this.agent = initCall.getAgent();
		try {
			//while ( true ) {
				// Get the value of the input for the next time
				// instant. This call may suspend.
				val value = port.get();
				
				if ( logger.isDebugEnabled())
					logger.debug( "value =" + value + " agent=" + agent);
				
				// The input to be executed at the next time instant
				// is now available. Provide the value for the input
				// variable. Note that this will cause the variable
				// input to become current, if necessary.
				
				initPromise.equate( value );
				
				try {
					// Run the agent for the current time instant.
					// This may throw an Abort. Aborts are propagated
					// out of the loop and cause the Vat to abort.
					agent.now();
					
					if ( logger.isDebugEnabled())
						logger.debug( "Running choicepoints");
					if (clock.collectedCP != null) clock.collectedCP.run();
				} catch (z:FailureException) {
					//Console.OUT.println("Vat agent.now() failed." + z);
					if (logger.isInfoEnabled())
						logger.info("The vat " + this + 
								" became inconsistent at " + 
								                           clock.timeStamp+".");
					failed=true;
				}
				
				// Compute the next agent.
				// Schedule all the "next" tasks now.
			//	if ( logger.isDebugEnabled()) logger.debug( "Computing nexts.");
			//	agent = agent.next();
				
				// Bump up the current time-step.
			//	clock.inc();
			//}
		} catch (z:Abort) {
			//z.printStackTrace();
			failed=true;
			if (logger.isInfoEnabled())
				logger.info("The Vat " + this + " has aborted at " + clock.timeStamp + ".");
			throw z;
		} finally {
			//Console.OUT.println("Vat. Exiting vat.runOnce()");
		}
	}
	
}
