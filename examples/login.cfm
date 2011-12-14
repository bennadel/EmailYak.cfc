
<!--- Param the setting values. --->
<cfparam name="form.key" type="string" default="" />
<cfparam name="form.callbackUrl" type="string" default="" />


<!--- 
	Check to see if the key and callback fields have a length 
	(basically that they were submitted with the form). 
--->
<cfif (
	len( form.key ) &&
	len( form.callbackUrl )
	)>

	<!--- 
		Persist the key in the application. It will be used for 
		all of the demo HTTP requests.
	--->
	<cfset application.apiKey = form.key />
	
	<!--- 
		Persist the demo callback directory. This will be the base
		directory used in all the callbacks sent to Email Yak.
	---> 
	<cfset application.callbackUrl = form.callbackUrl />
	
	<!--- Goto the homepage. --->
	<cflocation
		url="./index.cfm"
		addtoken="false"
		/>

</cfif>


<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!DOCTYPE html>
	<html>
	<head>
		<title>Email Yak API Key Login</title>
	</head>
	<body>
		
		<h1>
			Please Enter Your Email Yak Demo Settings
		</h1>
		
		<form method="post" action="#cgi.script_name#">
		
			<p>
				API Key:<br />
				<input type="password" name="key" size="20" />
			</p>
			
			<p>
				Callback URL:<br />
				<input type="password" name="callbackUrl" value="http://www.[YOUR DOMAIN HERE].com/emailyak/examples/push_email.cfm" size="50" />
			</p>
			
			<p>
				<input type="submit" value="Login" />
			</p>
		
		</form>
		
	</body>
	</html>

</cfoutput>