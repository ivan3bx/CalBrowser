## CalBrowser

A bare-bones browser for the [Google Calendar API](https://developers.google.com/google-apps/calendar/).
I took a look at Google's obj-c client, which has a few problems for me:

1. Bootstrapping took more than five minutes switching between random docs, and the code.
2. I don't want to integrate with all APIs, just calendar.  Pulling in the whole client just for a portion of it seemed wasteful.
3. I wanted something closer to the underlying JSON representation to build on top of.

This project is intended to be a starting point for more interesting projects, and will be pretty skeletal,
but over time will model the essential aspects of calendar interactions

### Bootstrap (5 minutes)

1. Clone the repo, install dependent [pods](http://beta.cocoapods.org) and open the workspace

		git clone git@github.com:ivan3bx/CalBrowser.git
		cd CalBrowser
		pod install
		open CalBrowser.xcworkspace

2. Create a new app in Google's ['Cloud Console'](https://cloud.google.com/console#/flows/enableapi?apiid=calendar)
3. In the cloud console, set up an 'iOS' style application.
4. Download the "OAuth 2.0 Client ID" data in JSON format, and save it in the root of your XCode project:

		ROOT_DIR/
		  -> CalBrowser/
		  	-> clientConfig.json

5. Create a simple JSON file in the following directory, holding the name of your Google Apps domain, such as `{"domain" : "example.com"}`

		ROOT_DIR/
		-> CalBrowser/
		    -> apps-domain.json

6. Build and run.  The app delegate will check and verify that the client configuration is correct.

### What does it do?
* OAuth interaction via [OAuth2Client](https://github.com/nxtbgthng/OAuth2Client).
* Wiring up for Google Calendar.
* Basic UI to perform authentication, and store the user account credentials.
* Minimal UI demonstrating a simple use case