<p align="center">
  <img src="https://raw.githubusercontent.com/CTKRocks/Google-Feud-iOS/master/GoogleFued/Guess%20My%20Search.png" />
  <img src="http://i.giphy.com/3oz8xGSqhN7yk8UJgI.gif" />
</p>

### Google Feud for iOS
Google Feud for iOS is an open-source Swift application for Apple's iOS. You can [download the app on the AppStore.](https://itunes.apple.com/us/app/guess-my-search/id1144264060?mt=8) Please use the code to learn from and not to copy from. Commit useful code to help shape this project.

### How to Compile
To compile this project install CocoaPods and install the Pods.

> NOTE: If you don't have cocoapods, install them with `sudo gem install cocoapods`

```shell
$ git clone https://github.com/CTKRocks/Google-Feud-iOS.git
$ cd PATH/TO/CLONE
$ pod install
```
Next you need to open the GoogleFeud.xcworkspace **NOT** the GoogleFeud.xcodeproj
Your ready to go! Take a look at the code and try it out on your iDevice!

### Features
Unlike other Google Feud apps, Guess My Search has categories, which are UIButtons that access different arrays containing the questions from Justin Hook's site Google Feud.
<p align="center">
  <img src="http://imgur.com/GXvfj9u.png" />
</p>

To get the data from Google, I use [Alamofire](https://github.com/Alamofire/Alamofire) along with [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) for parsing

### Authors and Contributors
Google Feud was originally created by Justin Hook. Take a look at [his site](http://googlefeud.com/).
Google Feud for iOS was developed by Carson Katri and published by Ryan Katri.

### Contact

[email](mailto:carson.katri@gmail.com)
