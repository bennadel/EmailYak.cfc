
<!---
	NOTE: The callback URL must provide a 200 OK response. If it does not, then the
	Email Yak SMTP Proxy will continue to ping this URL every 5 minutes for 120 hours
	until a 200 OK response is returned. Therefore, we are taking extra care to always
	return a 200 OK even if we have an internal error.
--->


<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	

<!--- Define a log file for local CFDump'ing. --->
<cfset logFile = (
	getDirectoryFromPath( getCurrentTemplatePath() ) & 
	"log.htm"
	) />


<!--- 
	Since we are dealing with an POST that may not be from a known
	source, let's wrap the processing in a Try/Catch where we can 
	handle errors more appropriately.
--->
<cftry>

	
	<!--- 
		Check to make sure the source is verified - that is, that Email Yak
		is the one that actually posted this email. 
	--->
	<cfif !emailYak.isRequestAuthenticated( getHttpRequestData() )>

		<!--- The digest does not match (or did not exist) - source may be malicious. --->
		<cfthrow 
			type="NotAuthorized" 
			message="Authorization failed."
			detail="The provided message digest did not match the calculated digest." 
			/>
	
	</cfif>


	<!--- Check to make sure the content is valid JSON. --->
	<cfif !isJSON( toString( getHttpRequestData().content ) )>
		
		<!--- Can't process this data. --->
		<cfthrow
			type="BadRequest"
			message="Request content must be valid JSON."
			detail="The content of the post was not valid JSON."
			/>
	
	</cfif>
	
	
	<!--- Parse the JSON content. --->
	<cfset response = deserializeJSON( 
		toString( getHttpRequestData().content ) 
		) />


	<!--- Log the email data that came through. --->
	<cfdump 
		var="#response#"
		output="#logFile#"
		hide="Headers" 
		format="html" 
		label="Email Yak Push Notification" 
		/>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!--- Catch any unspecified errors. --->
	<cfcatch>
	
		<!--- Log exception. --->
		<cfdump 
			var="#cfcatch#"
			output="#logFile#" 
			format="html" 
			label="CFCATCH - Unexpected Exception" 
			/>
	
	</cfcatch>

</cftry>



