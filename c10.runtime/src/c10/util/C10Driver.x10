package c10.util;
import c10.lang.*;
import c10.runtime.agent.Agent;
import c10.runtime.herbrand.Vat.InitCall;

public interface C10Driver[T]{T haszero} {
	
	def run(s:XRail[String], a:InitCall[T]):void;
}