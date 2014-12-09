package c10c;

import polyglot.frontend.Goal;
import polyglot.frontend.Job;
import polyglot.frontend.Scheduler;
import polyglot.types.TopLevelResolver;
import polyglot.types.TypeSystem;
import polyglot.visit.NodeVisitor;
import x10.X10CompilerOptions;
import x10.types.X10SourceClassResolver;
import x10c.types.X10CTypeSystem_c;
import x10cpp.postcompiler.PrecompiledLibrary;

/*
 *  This file is part of the C10 project (http://x10-lang.org).
 *
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 *
 *  (C) Copyright IBM Corporation 2014.
 */

public class ExtensionInfo extends x10c.ExtensionInfo{
	 @Override
	    public String[] fileExtensions() {
	        return new String[] { "c10", "x10"};
	    }
	    @Override
	    public String defaultFileExtension() {
	        return "c10";
	    }

	    @Override
	    public String compilerName() {
	        return "c10c";
	    }
	    @Override
	    protected TypeSystem createTypeSystem() {
	        return new X10CTypeSystem_c(this);
	    }
	    @Override
	    protected void initTypeSystem() {
	        X10CompilerOptions opts = getOptions();
	        TopLevelResolver r = new X10SourceClassResolver(compiler, this, opts.constructFullClasspath(),
	                                                        opts.compile_command_line_only,
	                                                        opts.ignore_mod_times);

	        for (PrecompiledLibrary pco : opts.x10libs) {
	            pco.updateManifest(manifest, this);
	        }

	        ts.initialize(r);
	    }

    @Override
    protected Scheduler createScheduler() {
        return new C10CScheduler(this);
    }
    static class DummyForgivingVisitorGoal extends polyglot.frontend.ForgivingVisitorGoal {
		private static final long serialVersionUID = -4731289189350458371L;
		public DummyForgivingVisitorGoal(String s, Job j, NodeVisitor n) {
    		super(s, j, n);
    	}
    	@Override public boolean runTask(){
			System.out.println("Dummy InitializationChecker invoked.");
			return true;
			}
    }
    static class DummyNodeVisitor extends NodeVisitor {}
    public static class C10CScheduler extends X10CScheduler {
        public C10CScheduler(ExtensionInfo extInfo) {
            super(extInfo);
        }

        @Override
        public ExtensionInfo extensionInfo() {
            return (ExtensionInfo) this.extInfo;
        }
 
        @Override
        public Goal InitializationsChecked(Job job) {
        	return new DummyForgivingVisitorGoal("DummyChecker", job, new DummyNodeVisitor()).intern(this);
        }
       
        
    }

}
