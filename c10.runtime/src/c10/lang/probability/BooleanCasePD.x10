package c10.lang.probability;

import c10.lang.*;
import c10.lang.Boolean;
import c10.lang.XRail;
public class BooleanCasePD[S](pds:XRail[PD[S]]) extends ConditionalPD[S,XBoolean]{
	public def this(d1:Boolean,  pds:XRail[PD[S]]) {
		super(d1);
		property(pds);
	}
	public def caseOf(v:XBoolean):PD[S] = v?pds(0):pds(1);
}