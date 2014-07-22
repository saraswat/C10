/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.herbrand;

/** An ActivationError is thrown whenever there is an error in
    activating a suspension.
    
   @author vj
*/
public class ActivationError extends Error {
    public def this() { super(); }
    public def this(z:Exception) { super( z.toString() ); }
}
