
<!--- 
	Param the emailID value (in this case, it will be a comma-delimited list 
	of email IDs).
--->
<cfparam name="url.emailID" type="string" default="" />


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Check to make sure we have at least one email ID to work with. --->
<cfif !listLen( url.emailID )>

	<!--- Reset the output buffer. --->
	<cfcontent type="text/html; charset=utf-8" />

	<!DOCTYPE html>
	<html>
	<head>
		<title>Get Email List - Requires A List Of Email ID</title>
	</head>
	<body>
	
		<h1>
			Get Email List - Requires A List Of Email ID
		</h1>
		
		<!--- 
			The user needs to get at least one EmailID in order to use this part of
			the API. Redirect them to the Get All Email page where the Get Email List 
			link can be activated. 
		--->
		<p>
			You need to get at least one Email ID first. Go to 
			<a href="./get_all_email.cfm">Get All Email</a> and click
			on the "Get Email List" link at the bottom.
		</p>
				
	</body>
	</html>

	<!--- Don't let this page continue processing without email IDs. --->
	<cfexit />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- 
	Get the email in the given list. For this demo we are gonna leave off the 
	GetHeaders argument which will default to False. This will keep the response 
	a bit more lightweight and not bring down all the Email Header name/value pairs.
--->
<cfset response = emailYak.getEmailList(
	emailID = url.emailID
	) />


<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Get Email List Response"
	/>
	
	