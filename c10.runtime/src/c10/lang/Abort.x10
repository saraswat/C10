/**
 * Released under the Eclipse Public Licence. Please see C10 project licence.
 * (c) IBM 2014
 */

/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.lang;

/** An Abort error is thrown when an agent aborts. Unless captured,
 * this results in the Vat being aborted.
    
 @author vj
 */
public  class Abort extends Exception {
    public def this()             {super();}
    public def this( z:Exception) {super( z.toString());}
    public def this(z: String )        {super(z);}
}
