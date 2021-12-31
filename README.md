
# onTV for iPAD

## Building

###@ first time

* install [Taskfile](https://taskfile.dev/#/installation)
* check you have latest [XCode](https://developer.apple.com/xcode/) if not update/install it
* open the workspace file and alter the signign settings with your certicate, if you do not have create one, then you can close xcode
* run `task init`
* then follow the next section
* install [ios-deploy](https://github.com/ios-control/ios-deploy#installation)

### after your env is initialise

* run `task install -- <UUID>` where >UUID> is the connected ipad id where you want to istall the app, you can find it from Xcode/Windows/Devices and Simlators it is called there Idendifier. 
* if you install the app for the first time or you change the certificate you will have to trust the new one on the ipad Settings/General/VPN & Device Management

