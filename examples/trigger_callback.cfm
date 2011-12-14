
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />


<!--- 
	In order to trigger the callback, we need to send an email address to ourselves.
	This will cause the new email to be pushed DOWN to the callback URL registered 
	for out Simple Yak domain. 
--->
<cfset response = emailYak.sendEmail(
	fromAddress = "ben@emailyakcfc.simpleyak.com",
	fromName = "Ben Nadel",
	toAddress = "ben@emailyakcfc.simpleyak.com",
	subject = "This is a test from EmailYak.cfc",
	htmlBody = "<p>Email Yak, it really whips the llama's ass.</p>",
	textBody = "Email Yak, it really whips the llama's ass."
	) />
	
	
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
	
	
<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!DOCTYPE html>
<html>
<head>
	<title>Email Push Triggered</title>
</head>
<body>

	<h1>
		Email Push Triggered
	</h1>
	
	<p>
		We just used Email Yak to send an email to ourselves! This
		will trigger an email push to our callback URL - 
		<strong>push_email.cfm</strong>.
	</p>
	
	<p>
		To view the callback response, go to 
		<a href="./log.htm" target="_blank">log.htm</a>.
	</p>
	
</body>
</html>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Send Email Response"
	/>
	
	