param($installPath, $toolsPath, $package, $project)
#$configItem = $project.ProjectItems.Item("NLog.config")
# set 'Copy To Output Directory' to ?'0:Never, 1:Always, 2:IfNewer'
#$configItem.Properties.Item("CopyToOutputDirectory").Value = 2
# set 'Build Action' to ?'0:None, 1:Compile, 2:Content, 3:EmbeddedResource'
#$configItem.Properties.Item("BuildAction").Value = 2

# .config\ExampleDevelopment\LogProcessorSettings.json
$configItem1022bd3e952c4a87bb527126451351ae = $project.ProjectItems.Item(".config").ProjectItems.Item("ExampleDevelopment").ProjectItems.Item("LogProcessorSettings.json")
$configItem1022bd3e952c4a87bb527126451351ae.Properties.Item("CopyToOutputDirectory").Value = 1
$configItem1022bd3e952c4a87bb527126451351ae.Properties.Item("BuildAction").Value = 2

# .config\ExampleProduction\LogProcessorSettings.json
$configItem8f0caa4191864b3397b116c29d978155 = $project.ProjectItems.Item(".config").ProjectItems.Item("ExampleProduction").ProjectItems.Item("LogProcessorSettings.json")
$configItem8f0caa4191864b3397b116c29d978155.Properties.Item("CopyToOutputDirectory").Value = 1
$configItem8f0caa4191864b3397b116c29d978155.Properties.Item("BuildAction").Value = 2

