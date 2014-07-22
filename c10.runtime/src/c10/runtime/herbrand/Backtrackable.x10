/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.herbrand;

/** The basic interface implemented by a handle to a Port.
 * @author vj
 */
public interface Backtrackable {
    def resetOnBacktrack( ):void;
}
