
<cfcomponent
	output="false"
	hint="I define the application settings and event handlers.">
	
	
	<!--- Define application settings. --->
	<cfset this.name = hash( getCurrentTemplatePath() ) />
	<cfset this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 ) />
	<cfset this.sessionManagement = false />
	
	<!--- Set up a mapping to the component library. --->
	<cfset this.mappings[ "/com" ] = (
		getDirectoryFromPath( getCurrentTemplatePath() ) &
		"../library/"
		) />
	
	
	<cffunction
		name="onApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the application.">
		
		<!--- Set the default Email Yak API key. --->
		<cfset application.apiKey = "" />
		
		<!--- Set up the callback URL for testing. --->
		<cfset application.callbackUrl = "" />
		
		<!--- Return true so the application can load. --->
		<cfreturn true />		
	</cffunction>
	
	
	<cffunction
		name="onRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the request.">
		
		<!--- Check for re-initialization flag. --->
		<cfif structKeyExists( url, "init" )>
		
			<!--- Re-initialize the application manually. --->
			<cfset this.onApplicationStart() />
		
		</cfif>
		
		<!--- Return true so the request can load. --->
		<cfreturn true />
	</cffunction>
	
	
	<cffunction
		name="onRequest"
		access="public"
		returntype="void"
		output="true"
		hint="I process the incoming request.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="script"
			type="string"
			required="true"
			hint="I am the script_name value requested by the user."
			/>
			
		<!--- 
			Check to see if the user has defined the API key. If 
			they have not, then they must "login" to supply and API 
			key for all the demos. 
		--->
		<cfif !len( application.apiKey )>
			
			<!--- Render the login. --->
			<cfinclude template="./login.cfm" />
		
			<!--- Nothing left to process in this event. --->
			<cfreturn />
		
		</cfif>
		
		<!--- 
			If we made it this far, then the user has supplied the 
			API key and can now use the demo Email Yak application.
			We can render any template they request.
		--->
		<cfinclude template="#arguments.script#" />
		
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>


