package c10;

public class ExtensionInfo extends x10.ExtensionInfo{
    @Override
    public String[] fileExtensions() {
        return new String[] { "c10"};
    }
    @Override
    public String defaultFileExtension() {
        return "c10";
    }

    @Override
    public String compilerName() {
        return "c10c";
    }


}
