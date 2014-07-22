package c10.tests.cc;


import c10.lang.*;
import c10.lang.Int;
import c10.lang.Rail;
import c10.runtime.herbrand.*;
import c10.util.CCDriver;
import c10.runtime.agent.*;

public class GaleShapley extends Vat.BasicInitCall[XRail[String]]{
	public def this() {super((XInt)=>new Rail[String]());}
	val N=2n; 
	val men=[[0n,1n],[1n,0n]], womanAtLevel=[[0n,1n],[1n,0n]];
	val women=[[0n,1n],[1n,0n]], manAtLevel=[[0n,1n],[1n,0n]];
	val lw = [new Int(), new Int()];
	def man(x:XInt, l:XInt) {
		val y = womanAtLevel(x)(l), m = men(x)(l);
		m <= lw(y);
		//if (m < lw(y)) man(x,l-1n);
		
	}
	public def getAgent() = new Now(()=>{
		for (i in 0n..1n) man(i, 2n);
		});
	public static def main(args:XRail[String]) {
		new CCDriver[XRail[String]]().run(args, new GaleShapley());
	}
}