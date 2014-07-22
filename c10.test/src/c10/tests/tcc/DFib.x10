/*
* jcc -- The Java Concurrent Constraint Programming Language
* Copyright (C) 2003 Vijay A Saraswat
* Please see ../../CopyRight.txt for the copyright declaration.
*/

package c10.tests.tcc;

import c10.lang.*;
import c10.lang.Int;
import c10.lang.Rail;
import c10.runtime.herbrand.*;
import c10.util.ConsoleDriver;
import c10.runtime.agent.*;

public class DFib extends Vat.BasicInitCall[XRail[String]] {
	public def this() {super((XInt)=>new Rail[String]());}
    public def getAgent():Agent {
	val v = [ new Int(), new Int(), new Int()];
	val sumLoop = new BasicAgent() {
		    public def now()  {
			(new Ask(v(2),
				 new Ask(v(1), 
					 new BasicAgent() {
					     public def now()  {
						 v(0).equate(new Int(v(2).getValue() + v(1).getValue()));
					     }}))).now();
			v(0).print(Console.OUT );
		    }
		public def next()=this;
		};
	class Shifter extends BasicAgent {
	    var i:x10.lang.Int;
	    var value:Int = new Int();
	    public def this(i:x10.lang.Int) { this.i = i;}
	    public def now()  { v(i).equate(value);}
	    public def next() { value = v(i-1).dereference() as Int; return this;}
	}
	val move1 = new Shifter(1n);
	val move2 = new Shifter(2n);
	return new Par([new Tell(v(0), new Int(0n)) as Agent,
				   new Next(new Tell(v(0), new Int(1n))),
				   sumLoop,
				   move1,
				   new Next(move2)]);
    }

    public static def main(args: XRail[String]) {
    	new ConsoleDriver().run(args, new DFib());
    }
}


