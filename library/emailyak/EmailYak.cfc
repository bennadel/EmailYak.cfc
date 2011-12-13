
<cfcomponent
	output="false"
	hint="I provide a wrapper to the Email Yak API v1.0 (http://emailyak.com).">
	
	
	<!--- 
		Define the status code, mostly for reference. If an HTTP request comes back
		with a bad status code (ie. non-200) AND a JSON body, the body will contain 
		information about the error:
		
		{
			Status: "403",
			Message: "Permission denied."
		}
	--->
	<cfset this.statusCodes = {} />
	<cfset this.statusCodes[ "200" ] = "Success." />
	<cfset this.statusCodes[ "402" ] = "Invalid JSON/XML. Malformed JSON/XML syntax." />
	<cfset this.statusCodes[ "403" ] = "Permission denied." />
	<cfset this.statusCodes[ "420" ] = "Internal Error. There was an error in the system." />
	<cfset this.statusCodes[ "421" ] = "Input Parameter Error." />
	<cfset this.statusCodes[ "423" ] = "API key does not exist." />
	<cfset this.statusCodes[ "424" ] = "Account disabled." />
	<cfset this.statusCodes[ "426" ] = "Domain has been disabled." />
	<cfset this.statusCodes[ "427" ] = "The domain is not registered with Email Yak." />
	<cfset this.statusCodes[ "428" ] = "The requested record is not found." />
	<cfset this.statusCodes[ "430" ] = "Account not allowed access to requested version of API." />
	<cfset this.statusCodes[ "431" ] = "Invalid Response Format. In the url, specify ../json/.. or ../xml/.." />
	<cfset this.statusCodes[ "432" ] = "Invalid Request Format. Needs to be JSON or XML." />
	<cfset this.statusCodes[ "503" ] = "Service is Temporarily Down. Please stand by." />
	
	
	<cffunction
		name="init"
		access="public"
		returntype="any"
		output="false"
		hint="I return an initialized component.">
		
		<!--- Define the arguments. --->
		<cfargument
			name="apiKey"
			type="string"
			required="true"
			hint="I am the Email Yak API key. This is required for all HTTP requests made to the Email Yak API."
			/>
			
		<!--- Store the API key. --->
		<cfset variables.apiKey = arguments.apiKey />
		
		<!--- Store the base URL for the v1.0 API. --->
		<cfset variables.apiBaseUrl = "https://api.emailyak.com/v1/#variables.apiKey#/json" />
		
		<!--- 
			Set up a variable to store the last HTTP response from any API request.
			This way, if we have errors, we'll have some way to determine relevant data. 
		--->
		<cfset variables.lastHttpResponse = "" />
		
		<!--- Return this object reference. --->
		<cfreturn this />		
	</cffunction>
	
	
	<cffunction
		name="deleteEmail"
		access="public"
		returntype="struct"
		output="false"
		hint="I delete the email with the given 8-character ID.">
		
		<!--- Define arguments. --->
		<cfargument
			name="emailID"
			type="string"
			required="true"
			hint="I am the 8-character ID assigned to the email that we are deleting."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "EmailID" ] = arguments.emailID />
		
		<!--- Post the data. --->
		<cfset local.response = this.postData(
			resource = "#variables.apiBaseUrl#/delete/email/",
			data = local.data
			) />
	
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="getAllEmail"
		access="public"
		returntype="struct"
		output="false"
		hint="I get upto 100 emails using the given offsets. If no domain is provided, Email Yak will return emails across all the registered domains. The emails are ordered chronologically in ascending order - the emails near End will be the newest. All emails returned will be marked as read and will no longer appear as a new email.">
		
		<!--- Define arguments. --->
		<cfargument
			name="domain"
			type="string"
			required="false"
			default=""
			hint="I am the optional domain to which to focus the email list."
			/>
			
		<cfargument
			name="getHeaders"
			type="boolean"
			required="false"
			default="false"
			hint="A boolean to flag whether or not all the email headers should be returned."
			/>
			
		<cfargument
			name="start"
			type="numeric"
			required="false"
			hint="The starting offset (starting at zero) at which to slice emails."
			/>
			
		<cfargument
			name="end"
			type="numeric"
			required="false"
			hint="The ending offset at which to slice emails."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "Domain" ] = arguments.domain />
		<cfset local.data[ "GetHeaders" ] = arguments.getHeaders />
		
		<!--- Add the start offset if available. --->
		<cfif structKeyExists( arguments, "start" )>
		
			<!--- Add the argument. --->
			<cfset local.data[ "Start" ] = arguments.start />
		
		</cfif>
		
		<!--- Add the end offset if available. --->
		<cfif structKeyExists( arguments, "end" )>
		
			<!--- Add the argument. --->
			<cfset local.data[ "End" ] = arguments.end />
		
		</cfif>
		
		<!--- Remove the domain if it is empty (not provided). --->
		<cfif !len( local.data.domain )>
		
			<!--- Remove the optional argument. --->
			<cfset structDelete( local.data, "domain" ) />
		
		</cfif>
		
		<!--- Get the data. --->
		<cfset local.response = this.getData(
			resource = "#variables.apiBaseUrl#/get/all/email/",
			data = local.data
			) />
		
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="getData"
		access="public"
		returntype="struct"
		output="false"
		hint="I get data from the Email Yak API using HTTP GET. I return the deserialized response.">
		
		<!--- Define arguments. --->
		<cfargument
			name="resource"
			type="string"
			required="true"
			hint="I am the API resource which we are getting."
			/>
			
		<cfargument
			name="data"
			type="any"
			required="false"
			default="#structNew()#"
			hint="I am the data being sent with the request as URL-encoded values."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			GET to the Email Yak API. This may throw an exception if the request
			times out.
		--->
		<cfhttp
			result="local.httpResponse"
			method="get"
			url="#arguments.resource#">
			
			<!--- Specify that we can accept JSON. --->
			<cfhttpparam
				type="header"
				name="accept"
				value="application/json; charset=utf-8"
				/>
				
			<!--- Pass in any additional data. --->
			<cfloop
				item="local.key"
				collection="#arguments.data#">
				
				<!--- Send URL parameter. --->
				<cfhttpparam
					type="url"
					name="#local.key#"
					value="#arguments.data[ local.key ]#"
					/>
				
			</cfloop>
				
		</cfhttp>
		
		<!--- Store the last API response. --->
		<cfset variables.lastHttpResponse = local.httpResponse />
		
		<!--- Parse the incoming JSON. --->
		<cfset local.response = deserializeJSON( 
			toString( local.httpResponse.fileContent ) 
			) />
		
		<!--- Return the API response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="getEmail"
		access="public"
		returntype="struct"
		output="false"
		hint="I get the email with the given ID. The email returned will be marked as read and will no longer appear as a new email.">
		
		<!--- Define arguments. --->
		<cfargument
			name="emailID"
			type="string"
			required="true"
			hint="I am the 8-character ID assigned to the email we are getting."
			/>
			
		<cfargument
			name="getHeaders"
			type="boolean"
			required="false"
			default="false"
			hint="A boolean to flag whether or not all the email headers should be returned."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "EmailID" ] = arguments.emailID />
		<cfset local.data[ "GetHeaders" ] = arguments.getHeaders />
		
		<!--- Get the data. --->
		<cfset local.response = this.getData(
			resource = "#variables.apiBaseUrl#/get/email/",
			data = local.data
			) />
	
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="getEmailList"
		access="public"
		returntype="struct"
		output="false"
		hint="I get all of the emails with the given IDs. The emails returned will be marked as read and will no longer appear as a new email.">
		
		<!--- Define arguments. --->
		<cfargument
			name="emailID"
			type="string"
			required="true"
			hint="I am the list of 8-character IDs."
			/>
			
		<cfargument
			name="getHeaders"
			type="boolean"
			required="false"
			default="false"
			hint="A boolean to flag whether or not all the email headers should be returned."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "EmailID" ] = arguments.emailID />
		<cfset local.data[ "GetHeaders" ] = arguments.getHeaders />
		
		<!--- Get the data. --->
		<cfset local.response = this.getData(
			resource = "#variables.apiBaseUrl#/get/email/list/",
			data = local.data
			) />
		
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="getHexDigest"
		access="public"
		returntype="string"
		output="false"
		hint="I take the given API key and the HTTP BODY and return the HEX digest for request authentication.">
		
		<!--- Define arguments. --->
		<cfargument
			name="content"
			type="string"
			required="true"
			hint="I am the string content of the post that we are verifying."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			We need to hash the body of the post using the MD5 algorithm. Let's 
			define a key specification using the Email Yak API key.
		--->
		<cfset local.secretKeySpec = createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init(
			toBinary( toBase64( variables.apiKey ) ),
			javaCast( "string", "HmacMD5" )
			) />
		
		<!--- 
			Now, let's create our MAC (Message Authentication Code) generator to hash
			the actual email post content.
		--->
		<cfset local.mac = createObject( "java", "javax.crypto.Mac" ).getInstance(
			javaCast( "string", "HmacMD5" )
			) />
			
		<!--- Initialize the MAC using our secret key. --->
		<cfset local.mac.init( local.secretKeySpec ) />
		
		<!--- Hash the content. --->
		<cfset local.hashedBytes = local.mac.doFinal(
			toBinary( toBase64( arguments.content ) )
			) />
		
		<!--- 
			Now we need to convert the bytes to a HEX string. We will need to convert
			each byte individually, so create a buffer to hold each HEX character.
		--->
		<cfset local.hexBuffer = [] />
		
		<!--- Loop over each byte. --->
		<cfloop
			index="local.byte"
			array="#local.hashedBytes#">
			
			<!--- 
				Get the HEX value. If a value comes through with a negative number, 
				it will be "padded" with "F" characters. As such, let's make sure 
				to only get the right-most 2 bits of the underlying byte.
				
				NOTE: We're using 255 insetad of 256 because we are using signed integers.
			--->
			<cfset local.hexChar = formatBaseN(
				bitAnd( local.byte, 255 ), 
				16
				) />
			
			<!--- 
				When appending, make sure the HEX value has 2 digits. The conversion
				will cut off the leading zero for values less that 10.
			--->
			<cfif (len( local.hexChar ) eq 1)>
			
				<!--- Prepend the padding zero. --->
				<cfset local.hexChar = ("0" & local.hexChar) />
			
			</cfif>
			
			<!--- Append 2-digit hex value. --->
			<cfset arrayAppend( local.hexBuffer, local.hexChar ) />
			
		</cfloop>
		
		<!--- Return the HEX digetst of the content. --->
		<cfreturn arrayToList( local.hexBuffer, "" ) />	
	</cffunction>
	
	
	<cffunction
		name="getNewEmail"
		access="public"
		returntype="struct"
		output="false"
		hint="I get upto 100 new (unread) emails using the given offsets. If no domain is provided, Email Yak will return new emails across all the registered domains. The emails are ordered chronologically in ascending order - the emails near End will be the newest. All emails returned will be marked as read and will no longer appear as a new email.">
		
		<!--- Define arguments. --->
		<cfargument
			name="domain"
			type="string"
			required="false"
			default=""
			hint="I am the optional domain to which to focus the email list."
			/>
			
		<cfargument
			name="getHeaders"
			type="boolean"
			required="false"
			default="false"
			hint="A boolean to flag whether or not all the email headers should be returned."
			/>
			
		<cfargument
			name="start"
			type="numeric"
			required="false"
			hint="The starting offset (starting at zero) at which to slice emails."
			/>
			
		<cfargument
			name="end"
			type="numeric"
			required="false"
			hint="The ending offset at which to slice emails."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "Domain" ] = arguments.domain />
		<cfset local.data[ "GetHeaders" ] = arguments.getHeaders />
		
		<!--- Add the start offset if available. --->
		<cfif structKeyExists( arguments, "start" )>
		
			<!--- Add the argument. --->
			<cfset local.data[ "Start" ] = arguments.start />
		
		</cfif>
		
		<!--- Add the end offset if available. --->
		<cfif structKeyExists( arguments, "end" )>
		
			<!--- Add the argument. --->
			<cfset local.data[ "End" ] = arguments.end />
		
		</cfif>
		
		<!--- Remove the domain if it is empty (not provided). --->
		<cfif !len( local.data.domain )>
		
			<!--- Remove the optional argument. --->
			<cfset structDelete( local.data, "domain" ) />
		
		</cfif>
		
		<!--- Get the data. --->
		<cfset local.response = this.getData(
			resource = "#variables.apiBaseUrl#/get/new/email/",
			data = local.data
			) />
		
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="isRequestAuthenticated"
		access="public"
		returntype="boolean"
		output="false"
		hint="I determine if the given HTTP request is authentic - that is, did it come from the Email Yak API or is it a fraudulent request.">
		
		<!--- Define arguments. --->
		<cfargument
			name="httpRequest"
			type="any"
			required="true"
			hint="I am the HTTP request that is being authenticated (expecting the value found in getHttpRequestData())."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- Get a reference to the HTTP headers. --->
		<cfset local.headers = arguments.httpRequest.headers />
	
		<!--- Make sure the Email Yak auth key exists. --->
		<cfif !structKeyExists( local.headers, "X-Emailyak-Post-Auth" )>
			
			<!--- We can't authorize with out the right headers. --->
			<cfreturn false />
			
		</cfif>
		
		<!--- Get the secure MD5 hash digest of the content using our API key. --->
		<cfset local.hexDigest = this.getHexDigest(
			toString( arguments.httpRequest.content )
			) />
			
		<!--- Check to make sure the digests match. --->
		<cfif (local.headers[ "X-Emailyak-Post-Auth" ] neq local.hexDigest)>
			
			<!--- The digest does not match - source is probably malicious. --->
			<cfreturn false />
		
		</cfif>

		<!--- 
			If we made it this far then nothing in the authentication failed. The 
			source has been verified as being Email Yak. 
		--->
		<cfreturn true />
	</cffunction>
	
	
	<cffunction
		name="postData"
		access="public"
		returntype="struct"
		output="false"
		hint="I post data to the Email Yak API using HTTP POST. I return the deserialized response.">
		
		<!--- Define arguments. --->
		<cfargument
			name="resource"
			type="string"
			required="true"
			hint="I am the API resource to which we are posting."
			/>
			
		<cfargument
			name="data"
			type="any"
			required="true"
			hint="I am the data being posted (this will be serialized as JSON internally for the HTTP POST)."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Post to the Email Yak API. This may throw an exception if the request
			times out.
		--->
		<cfhttp
			result="local.httpResponse"
			method="post"
			url="#arguments.resource#">
			
			<!--- Set the content type to be JSON. --->
			<cfhttpparam
				type="header"
				name="content-type"
				value="application/json; charset=utf-8"
				/>
				
			<!--- Specify that we can accept JSON as well. --->
			<cfhttpparam
				type="header"
				name="accept"
				value="application/json; charset=utf-8"
				/>
				
			<!--- Post the data. --->
			<cfhttpparam
				type="body"
				value="#serializeJSON( arguments.data  )#"
				/>
	
		</cfhttp>
		
		<!--- Store the last API response. --->
		<cfset variables.lastHttpResponse = local.httpResponse />
		
		<!--- Parse the incoming JSON. --->
		<cfset local.response = deserializeJSON( 
			toString( local.httpResponse.fileContent ) 
			) />
		
		<!--- Return the API response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="registerAddress"
		access="public"
		returntype="struct"
		output="false"
		hint="I register a new email address that can be used to send and receive email. An email address can override the domain-level settings for callbacks and push notification. If the given address already exists, the existing record will be overriden.">
		
		<!--- Define arguments. --->
		<cfargument
			name="address"
			type="string"
			required="true"
			hint="I am the address being registered for incoming and outgoing emails."
			/>
			
		<cfargument
			name="callbackUrl"
			type="string"
			required="false"
			default=""
			hint="I am the callback URL for push notifications. A POST request will be sent to the URL provided with information about the email received. If a CallbackURL is specified for both the domain and an address, only the Address CallbackURL will be sent a POST request."
			/>
		
		<cfargument
			name="pushEmail"
			type="boolean"
			required="false"
			default="false"
			hint="I flag whether or not this address will use push notification for incoming emails. "
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "Address" ] = arguments.address />
		<cfset local.data[ "CallbackURL" ] = arguments.callbackUrl />
		<cfset local.data[ "PushEmail" ] = arguments.pushEmail />
		
		<!--- Remove the callback if it is empty (not provided). --->
		<cfif !len( local.data.callbackUrl )>
		
			<!--- Remove the optional argument. --->
			<cfset structDelete( local.data, "callbackUrl" ) />
		
		</cfif>
		
		<!--- Post the data. --->
		<cfset local.response = this.postData(
			resource = "#variables.apiBaseUrl#/register/domain/",
			data = local.data
			) />
	
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="registerDomain"
		access="public"
		returntype="struct"
		output="false"
		hint="I register a new domain at which we can define email addresses to send and receive from. For testing purposes, this can be sub-domains off of the simpleyak.com testing domain.">
		
		<!--- Define arguments. --->
		<cfargument
			name="domain"
			type="string"
			required="true"
			hint="I am the domain being registered."
			/>
			
		<cfargument
			name="callbackUrl"
			type="string"
			required="false"
			default=""
			hint="I am the callback URL for push notifications. A POST request will be sent to the URL provided with information about the email received. If a CallbackURL is specified for both the domain and an address, only the Address CallbackURL will be sent a POST request."
			/>
		
		<cfargument
			name="pushEmail"
			type="boolean"
			required="false"
			default="false"
			hint="I flag whether or not this domain will use push notification for incoming emails. "
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "Domain" ] = arguments.domain />
		<cfset local.data[ "CallbackURL" ] = arguments.callbackUrl />
		<cfset local.data[ "PushEmail" ] = arguments.pushEmail />
		
		<!--- Remove the callback if it is empty (not provided). --->
		<cfif !len( local.data.callbackUrl )>
		
			<!--- Remove the optional argument. --->
			<cfset structDelete( local.data, "callbackUrl" ) />
		
		</cfif>
		
		<!--- Post the data. --->
		<cfset local.response = this.postData(
			resource = "#variables.apiBaseUrl#/register/domain/",
			data = local.data
			) />
	
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
	
	
	<cffunction
		name="sendEmail"
		access="public"
		returntype="struct"
		output="false"
		hint="I send the given email using the Email Yak API.">
		
		<!--- Define arguments. --->
		<cfargument
			name="fromAddress"
			type="string"
			required="true"
			hint="I am the email address to appear in the From header field. If this email has not yet been registered, it will be registered automatically to send and receive email going forward."
			/>
		
		<cfargument
			name="fromName"
			type="string"
			required="false"
			default=""
			hint="I am the name associated with the outgoing address. If provided, it will be combined with the FromAddress."
			/>
		
		<cfargument
			name="senderAddress"
			type="string"
			required="false"
			default=""
			hint="I am an email address belonging to a (sub)domain registered with Email Yak. The address provided will be used to send the email. If provided, the FromAddress can be any valid email address, including those not registered with Email Yak (e.g. name@gmail.com). If it is not registered with Email Yak, it will be registered and can be used to send and receive email."
			/>
		
		<cfargument
			name="toAddress"
			type="string"
			required="true"
			hint="I am the email address, or comma-delimited list of email address to which the email is being sent."
			/>
		
		<cfargument
			name="replyToAddress"
			type="string"
			required="false"
			default=""
			hint="I am the optional address to be used as the Reply-To header field."
			/>
		
		<cfargument
			name="ccAddress"
			type="string"
			required="false"
			default=""
			hint="I am the email address, or comma-delimited list of email addresses to be CCd on the email."
			/>
			
		<cfargument
			name="bccAddress"
			type="string"
			required="false"
			default=""
			hint="I am the email address, or comma-delimited list of email addresses to be BCCd on the email."
			/>
			
		<cfargument
			name="subject"
			type="string"
			required="false"
			default=""
			hint="I am the subject of the outgoing email."
			/>
			
		<cfargument
			name="htmlBody"
			type="string"
			required="false"
			default=""
			hint="I am the HTML formatted body of the outgoing email. If it is supplied, the outgoing email will have both TEXT and HTML parts."
			/>
			
		<cfargument
			name="textBody"
			type="string"
			required="true"
			hint="I am the TEXT formatted body of the outgoing email."
			/>
			
		<cfargument
			name="headers"
			type="array"
			required="false"
			default="#arrayNew( 1 )#"
			hint="I am a collection of Name/Value pairs that can be added to the email header fields."
			/>
			
		<cfargument
			name="attachments"
			type="array"
			required="false"
			default="#arrayNew( 1 )#"
			hint="I am a collection of Filename/Content pairs that can be attached to the outgoing email. Content must be defined as a Base64-encoded string."
			/>
			
		<!--- Define the local scope. --->
		<cfset var local = {} />
		
		<!--- 
			Package the data for posting. Use bracket notation to maintain case 
			sensitivity for subsequent JSON serialization.
		--->
		<cfset local.data = {} />
		<cfset local.data[ "FromAddress" ] = arguments.fromAddress />
		<cfset local.data[ "FromName" ] = arguments.fromName />
		<cfset local.data[ "SenderAddress" ] = arguments.senderAddress />
		<cfset local.data[ "ToAddress" ] = arguments.toAddress />
		<cfset local.data[ "ReplyToAddress" ] = arguments.replyToAddress />
		<cfset local.data[ "CcAddress" ] = arguments.ccAddress />
		<cfset local.data[ "BccAddress" ] = arguments.bccAddress />
		<cfset local.data[ "Subject" ] = arguments.subject />
		<cfset local.data[ "HtmlBody" ] = arguments.htmlBody />
		<cfset local.data[ "TextBody" ] = arguments.textBody />
		<cfset local.data[ "Headers" ] = [] />
		<cfset local.data[ "Attachments" ] = [] />
		
		<!--- Popluate the headers collection with case-appropriate values. --->
		<cfloop
			index="local.header"
			array="#arguments.headers#">
				
			<!--- Create a new header pair. --->
			<cfset local.headerData = {} />
			<cfset local.headerData[ "Name" ] = local.header.name />
			<cfset local.headerData[ "Value" ] = local.header.value />
			
			<!--- Add the header to the outgoing data. --->
			<cfset arrayAppend( local.data.headers, local.headerData ) />
			
		</cfloop>
		
		<!--- Popluate the attachments collection with case-appropriate values. --->
		<cfloop
			index="local.attachment"
			array="#arguments.attachments#">
				
			<!--- Create a new attachment pair. --->
			<cfset local.attachmentData = {} />
			<cfset local.attachmentData[ "Filename" ] = local.attachment.filename />
			<cfset local.attachmentData[ "Content" ] = local.attachment.content />
			
			<!--- Add the attachment to the outgoing data. --->
			<cfset arrayAppend( local.data.attachments, local.attachmentData ) />
			
		</cfloop>
		
		<!--- 
			Remove optional parameters if not provided. For simplicity, we'll only do 
			this with string-values. If the attachments or headers collections are empty, 
			we'll pass them along anyway. 
		--->
		<cfloop
			index="local.parameter"
			list="fromName, senderAddress, replyToAddress, ccAddress, bccAddress, subject, htmlBody"
			delimiters=", ">
			
			<!--- Check to see if the parameter was provided (ie. is not empty). --->
			<cfif !len( local.data[ local.parameter ] )>
			
				<!--- Remove the optional argument. --->
				<cfset structDelete( local.data, local.parameter ) />
			
			</cfif>
			
		</cfloop>
		
		<!--- Post the data. --->
		<cfset local.response = this.postData(
			resource = "#variables.apiBaseUrl#/send/email/",
			data = local.data
			) />
	
		<!--- Return the response. --->
		<cfreturn local.response />
	</cffunction>
		
</cfcomponent>








































