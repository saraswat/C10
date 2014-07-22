package c10.lang.probability;

import c10.lang.*;
import c10.lang.Boolean;
import c10.lang.XRail;
public class BooleanCasePD2[S](pds:XRail[PD[S]]) extends ConditionalPD2[S,XBoolean,XBoolean]{
	public def this(d1:Boolean, d2:Boolean, pds:XRail[PD[S]]) {
		super(d1,d2);
		property(pds);
	}
	public def caseOf(v1:XBoolean, v2:XBoolean):PD[S] = v1?(v2?pds(0):pds(1)):(v2?pds(2):pds(3));
}