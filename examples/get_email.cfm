
<!--- Param the emailID value. --->
<cfparam name="url.emailID" type="string" default="" />


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Check to make sure we have an email ID to work with. --->
<cfif !len( url.emailID )>

	<!--- Reset the output buffer. --->
	<cfcontent type="text/html; charset=utf-8" />

	<!DOCTYPE html>
	<html>
	<head>
		<title>Get Email - Requires An Email ID</title>
	</head>
	<body>
	
		<h1>
			Get Email - Requires An Email ID
		</h1>
		
		<!--- 
			The user needs to get an EmailID in order to use this part of the 
			API. Redirect them to the Get All Email page where the subject lines 
			can be activated. 
		--->
		<p>
			You need to get an Email ID first. Go to 
			<a href="./get_all_email.cfm">Get All Email</a>
			in order to get the details of a given email.
		</p>
				
	</body>
	</html>

	<!--- Don't let this page continue processing without an ID. --->
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
	Get the email. For this demo we are gonna leave off the GetHeaders argument which
	will default to False. This will keep the response a bit more lightweight and not 
	bring down all the Email Header name/value pairs.
--->
<cfset response = emailYak.getEmail(
	emailID = url.emailID
	) />


<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Get Email Response"
	/>
	
	