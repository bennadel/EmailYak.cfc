
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- Register the testing domain for the EmailYak.cfc project. --->
<cfset response = emailYak.registerDomain(
	domain = "emailyakcfc.simpleyak.com",
	callbackUrl = application.callbackUrl,
	pushEmail = true
	) />
	
	
<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Register Domain Response"
	/>