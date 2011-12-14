
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- 
	Register the testing email address for the EmailYak.cfc project. For this
	demo, we are leaving out the Callback and PushEmail arguments overrides since
	we will be using the same values set at the domain level (see register_domain.cfm
	for more details). 
--->
<cfset response = emailYak.registerAddress(
	address = "ben@emailyakcfc.simpleyak.com"
	) />
	
	
<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Register Address Response"
	/>