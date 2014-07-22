/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.runtime.herbrand;
import c10.lang.Herbrand;

/** The basic interface implemented by a Choice Point, such as an ElseNow.
 * @author vj
 */
public interface ChoicePoint {
    def pushTrail( b:Backtrackable):void;
    def ensureKnowns():void;
    def pushEnsureKnown( p:Herbrand[Any]):void;
    def popEnsureKnown( ):void;
    def run():void;
}
