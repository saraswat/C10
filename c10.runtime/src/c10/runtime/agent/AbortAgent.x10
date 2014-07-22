/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.agent;
import c10.lang.Abort;

/** The abort agent. Throws an abort when executed.
 @author vj
 */
public class AbortAgent extends BasicAgent {
    public def now():void {throw new Abort();}
    public def toString()="AbortAgent";
}
