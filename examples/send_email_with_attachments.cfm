
<!--- Create an instance of the Email Yak wrapper. --->
<cfset emailYak = createObject( "component", "com.emailyak.EmailYak" ).init(
	application.apiKey
	) />
	
	
<!--- 
	When sending attachments, they need to be encoded as Base64 strings.
	Therefore, when we read in the binary, we simply have to encode them. 
--->
<cfset attachments = [
	{
		filename = "alisha_morrow.jpg",
		content = toBase64( fileReadBinary( expandPath( "./attachments/alisha_morrow.jpg" ) ) )
	},
	{
		filename = "jen_rish.jpg",
		content = toBase64( fileReadBinary( expandPath( "./attachments/jen_rish.jpg" ) ) )
	}	
	] />
	
	
<!--- Send an email with attachments. --->
<cfset response = emailYak.sendEmail(
	fromAddress = "ben@emailyakcfc.simpleyak.com",
	fromName = "Ben Nadel",
	toAddress = "ben@bennadel.com",
	subject = "This is a test from EmailYak.cfc",
	htmlBody = "<p>Email Yak, it really whips the llama's ass.</p>",
	textBody = "Email Yak, it really whips the llama's ass.",
	attachments = attachments
	) />
	
	
<!--- Output the response. --->
<cfdump 
	var="#response#"
	label="Send Email Response"
	/>