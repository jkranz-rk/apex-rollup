public without sharing class RollupPlugin {
  @TestVisible
  private static List<RollupPlugin__mdt> pluginMocks;
  @TestVisible
  private static RollupPluginParameter__mdt parameterMock;

  public RollupPlugin__mdt getInstance(String developerNameOrId) {
    return pluginMocks != null && pluginMocks.isEmpty() == false ? pluginMocks.remove(0) : RollupPlugin__mdt.getInstance(developerNameOrId);
  }

  public List<RollupPlugin__mdt> getInstances() {
    List<RollupPlugin__mdt> plugins = new List<RollupPlugin__mdt>();
    plugins.addAll(RollupPlugin__mdt.getAll().values());
    if (pluginMocks != null) {
      plugins.addAll(pluginMocks);
    }
    return plugins;
  }

  public RollupPluginParameter__mdt getParameterInstance(String developerNameOrId) {
    return parameterMock != null ? parameterMock : RollupPluginParameter__mdt.getInstance(developerNameOrId);
  }

  public List<RollupPluginParameter__mdt> getMatchingParameters(Id pluginId) {
    List<RollupPluginParameter__mdt> pluginParameters = new List<RollupPluginParameter__mdt>();
    pluginParameters.addAll(RollupPluginParameter__mdt.getAll().values());
    if (parameterMock != null) {
      pluginParameters.add(parameterMock);
    }
    for (Integer index = pluginParameters.size() - 1; index >= 0; index--) {
      RollupPluginParameter__mdt pluginParameter = pluginParameters[index];
      if (pluginParameter.RollupPlugin__c != null && pluginParameter.RollupPlugin__c != pluginId) {
        pluginParameters.remove(index);
      }
    }
    return pluginParameters;
  }
}
