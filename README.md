
EmailYak.cfc - A ColdFusion component to wrap the EmailYak.com API.
===================================================================

Email Yak is a JSON-based SMTP proxy that acts as a go-between for your web-based
application and your user. Through the API, your web application can send emails to
your users. Your users can then respond to said emails using their native email client
(GMail, Apple Mail, Hotmail, Yahoo! Mail, etc.). When an email comes in from a user,
the Email Yak API will parse it, store the attachments, and push a "new email" 
notification to your web application's callback URL.

The EmailYak.cfc ColdFusion component provides simple methods for interacting with the
Email Yak JSON API. There are also a number of demo files that show how the ColdFusion
component can be used.

Email Yak Features In Demo
--------------------------

- Register Domain
- Register Email Address
- Send Email
- Send Email with Attachments
- Get All Email
- Get New Email
- Get Email
- Get Email List
- Delete Email
- Trigger Callback

**REQUIRED**: In order to use the demo, you have to have an Email Yak API key and a 
public callback URL (for push notification). When you open up the demo, it will ask
you to provide this information as part of the demo login.