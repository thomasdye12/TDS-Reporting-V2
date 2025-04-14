## TDS Reporting 


This is just something i created in a night, to allow us to report and mangage system and other house related issues all in one place.


This is a smiple IOS app that connects to a monogBD server, some chanes will be needed for your implementation to work, however the code is simple and easy to follow.


## Features
- Report issues
- View issues
- View all issues
- APNS


## Changes you might need to make

- Auth - everywhere auth is used, on the server there are a few thing to look users up, and in the IOS app auth handles the login, and APNS, as well as provides the JWT for that, these changes can be removed quickely, or sorted out by your own auth implementation.

