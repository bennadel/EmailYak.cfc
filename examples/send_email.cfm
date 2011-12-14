
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- Send an email. --->
<cfset response = emailYak.sendEmail(
	fromAddress = "ben@emailyakcfc.simpleyak.com",
	fromName = "Ben Nadel",
	toAddress = "ben@bennadel.com",
	subject = "This is a test from EmailYak.cfc",
	htmlBody = "<p>Email Yak, it really whips the llama's ass.</p>",
	textBody = "Email Yak, it really whips the llama's ass."
	) />
	
	
<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Send Email Response"
	/>