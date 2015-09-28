# ModPList

Modifies Delphi generated `.plist` files from a [Build-Event].

## Arguments

- `-f=<Target-File>`, `-file <Target-File>` (**Recommended**)

    Path to the `.plist` file that will be modified.

    Makro to use inside build events: `-f="$(OUTPUTPATH).info.plist"`

- `-ct`, `-checktarget` (*Optional*)

  Check existence of Target-File.

  If Target-File not exists the exit code is **3**.

- `-p=<Platform>`, `-platform <Platform>` (*Optonal*)

  Platform identifier

  Makro to use in build events: `-p="$(Platform)"`

- `-c=<Config>`, `-config <Config>` (*Optional*)

  Config

  Makro to use in build events: `-c="$(Config)"`

- `-i=<Path>[,<Path>]`, `-include <Path>[,<Path>]` (*Optional*)

  Include directory or file paths for `.plist` template files.

  Makro to use in build events: `-i="$(PROJECTDIR)","$(INCLUDEPATH)"`

## Modify

### String-Value

The whole file is scanned for string values `<string>...</string>` and replace the following values

Original | Replace with
:--- | :---
`<string>bool:true</string>` | `<true/>`
`<string>bool:false</string>` | `<false/>`

### Include-Files

All values from the Include-File are copied to the Target-File. Existing values with the same key in the Target-File will be overwritten.

Each directory Include-Path will be scanned for the following files in this order:

- `Include.Info.plist`
- `Include.<Config>.Info.plist` (if *config* was set)
- `Include.<Platform[3]>.Info.plist` (if *platform* was set)
- `Include.<Platform[3]>.<Config>.Info.plist` (if *platform*/*config* were set)
- `Include.<Platform>.Info.plist` (if *platform* was set)
- `Include.<Platform>.<Config>.Info.plist` (if *platform*/*config* were set)

**Example**

```
ModPList.exe -f="$(OUTPUTPATH).Info.plist" -p=iOSDevice32` -c=Release -i="$(PROJECTDIR)"
```

will look for the following Include-Files

- `$(PROJECTDIR)\Include.Info.plist`
- `$(PROJECTDIR)\Include.Release.Info.plist`
- `$(PROJECTDIR)\Include.iOS.Info.plist`
- `$(PROJECTDIR)\Include.iOS.Release.Info.plist`
- `$(PROJECTDIR)\Include.iOSDevice32.Info.plist`
- `$(PROJECTDIR)\Include.iOSDevice32.Release.Info.plist`

and copy the values if the file exists.

To fix the [iOS9 issue with `TWebBrowser`][1] and [ERROR ITMS-90507: Missing Info.plist value. A value for the key 'DTPlatformName' is required][2] create a `Include.iOS.Info.plist` in the project directory with the following content
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
<plist version="1.0">
  <dict>
    <key>DTPlatformName</key>
    <string>iphoneos</string>
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

`"<Path to ModPList>" -p="$(Platform)" -c="$(Config)" -f="$(OUTPUTPATH).info.plist" -i="$(PROJECTDIR)","$(INCLUDEPATH)"`

You can set a global [Environment-Variable] with the path to the ModPList application

Variable | Value
:--- | :---
`ModPList` | `C:\MyTools\ModPList\ModPList.exe`

and then use this for the Build-Event

`"$(ModPList)" -p="$(Platform)" -c="$(Config)" -f="$(OUTPUTPATH).info.plist" -i="$(PROJECTDIR),$(INCLUDEPATH)"`

[1]: http://community.embarcadero.com/blogs/entry/how-to-use-custom-info-plist-xml-to-support-ios-9-s-new-app-transport-security-feature
[2]: https://community.embarcadero.com/article/articles-support/176-rad-studio/usability/16049-error-itms-90507-missing-info-plist-value-a-value-for-the-key-dtplatformname-is-required-when-submitting-an-app-to-the-ios-app-store
[Build-Event]: http://docwiki.embarcadero.com/RADStudio/Seattle/en/Build_Events
[Environment-Variable]: http://docwiki.embarcadero.com/RADStudio/Seattle/en/Environment_Variables
