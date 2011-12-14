
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- Get the 100 (at most) NEW emails. --->
<cfset response = emailYak.getNewEmail(
	domain = "emailyakcfc.simpleyak.com",
	getHeaders = true
	) />
	
	
<!--- Create an array to keep hold of the email IDs that come down. --->
<cfset emailIDCollection = [] />
	
	
<!--- Output the list of subjects with links to the email detail. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!DOCTYPE html>
	<html>
	<head>
		<title>Get New Email</title>
	</head>
	<body>
		
		<h1>
			Get New Email
		</h1>
		
		<ol>
			<!--- Loop over the emails. --->
			<cfloop
				index="email"
				array="#response.emails#">
				
				<!--- Store this email ID. --->
				<cfset arrayAppend( emailIDCollection, email.emailID ) />
				
				<!--- 
					Parse the date field (replace the "T" with a space to separate 
					the date and time values).
				--->
				<cfset dateSent = parseDateTime( 
					replace( email.received, "T", " ", "one" ) 
					) />
				
				<li>
					<a href="./get_email.cfm?emailID=#email.emailID#">#htmlEditFormat( email.subject )#</a>
					(sent on #dateFormat( dateSent, "mmm d, yyyy" )# at #timeFormat( dateSent, "h:mm TT" )#).
				</li>
				
			</cfloop>
		</ol>
		
		
		<p>
			Click on the subject lines, or 
			<a href="./get_email_list.cfm?emailID=#arrayToList( emailIDCollection )#">Get Email List</a>.
		</p>
		
	</body>
	</html>

</cfoutput>
	
	
<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Get New Email Response"
	/>
	
	