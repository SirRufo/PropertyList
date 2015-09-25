# ModPList

Modifies Delphi generated `.plist` files from a [Build-Event].

## Arguments

- `-p=<Platform>`, `-platform <Platform>` (**Recommended**)

  Platform identifier

  Makro to use in build events: `-p="$(Platform)"`

- `-c=<Config>`, `-config <Config>` (**Recommended**)

  Config

  Makro to use in build events: `-c="$(Config)"`

- `-f=<Target-File>`, `-file <Target-File>` (**Recommended**)

    Path to the `.plist` file that will be modified.

    Makro to use inside build events: `-f="$(OUTPUTPATH).info.plist"`

- `-i=<Path>[,<Path>]`, `-include <Path>[,<Path>]` (Optional)

  Include paths for `.plist` template files.

  Makro to use in build events: `-i="$(PROJECTDIR),$(INCLUDEPATH)"`

## Modify

### String-Value

The whole file is scanned for string values `<string>...</string>` and replace the following values

Original | Replace with
:--- | :---
`<string>bool:true</string>` | `<true/>`
`<string>bool:false</string>` | `<false/>`

### Include-Files

All values from the Include-File are copied to the Target-File. Existing values with the same key in the Target-File will be overwritten.

Each Include-Path will be scanned for the following files in this order:

- `Include.Info.plist`
- `Include.<Config>.Info.plist`
- `Include.<Platform[3]>.Info.plist`
- `Include.<Platform[3]>.<Config>.Info.plist`
- `Include.<Platform>.Info.plist`
- `Include.<Platform>.<Config>.Info.plist`

**Example**

- Platform: `iOSDevice32`
- Config: `Release`
- Include-Path: `$(PROJECTDIR)`

will look for the following Include-Files

- `$(PROJECTDIR)\Include.Info.plist`
- `$(PROJECTDIR)\Include.Release.Info.plist`
- `$(PROJECTDIR)\Include.iOS.Info.plist`
- `$(PROJECTDIR)\Include.iOS.Release.Info.plist`
- `$(PROJECTDIR)\Include.iOSDevice32.Info.plist`
- `$(PROJECTDIR)\Include.iOSDevice32.Release.Info.plist`

and copy the values if the file exists.

To fix the [iOS9 issue with `TWebBrowser`][1] create a `Include.iOS.Info.plist` in the project directory with the following content
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
<plist version="1.0">
  <dict>
    <key>NSAppTransportSecurity</key>
    <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
    </dict>
  </dict>
</plist>
```
That's all with a configured Post-Build-Event.

## Build event

The best place for calling this application is in the Post-[Build-Event] of the project. A common configuration will look like this:

`"<Path to ModPList>" -p="$(Platform)" -c="$(Config)" -f="$(OUTPUTPATH).info.plist" -i="$(PROJECTDIR),$(INCLUDEPATH)"`

You can set a global [Environment-Variable] with the path to the ModPList application

Variable | Value
:--- | :---
`ModPList` | `C:\MyTools\ModPList\ModPList.exe`

and then use this for the Build-Event

`"$(ModPList)" -p="$(Platform)" -c="$(Config)" -f="$(OUTPUTPATH).info.plist" -i="$(PROJECTDIR),$(INCLUDEPATH)"`

[1]: http://community.embarcadero.com/blogs/entry/how-to-use-custom-info-plist-xml-to-support-ios-9-s-new-app-transport-security-feature
[Build-Event]: http://docwiki.embarcadero.com/RADStudio/Seattle/en/Build_Events
[Environment-Variable]: http://docwiki.embarcadero.com/RADStudio/Seattle/en/Environment_Variables
