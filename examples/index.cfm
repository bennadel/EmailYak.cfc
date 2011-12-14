
<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!DOCTYPE html>
	<html>
	<head>
		<title>EmailYak.cfc - Email Yak ColdFusion Component Wrapper</title>
	</head>
	<body>
		
		<h1>
			EmailYak.cfc - Email Yak ColdFusion Component Wrapper
		</h1>
		
		<ul>
			<li>
				<a href="./register_domain.cfm">Register Domain</a>
			</li>
			<li>
				<a href="./register_address.cfm">Register Email Address</a>
			</li>
			<li>
				<a href="./send_email.cfm">Send Email</a>
			</li>
			<li>
				<a href="./send_email_with_attachments.cfm">Send Email with Attachments</a>
			</li>
			<li>
				<a href="./get_all_email.cfm">Get All Email</a>
			</li>
			<li>
				<a href="./get_new_email.cfm">Get New Email</a>
			</li>
			<li>
				<a href="./get_email.cfm">Get Email</a>
			</li>
			<li>
				<a href="./get_email_list.cfm">Get Email List</a>
			</li>
			<li>
				<a href="./delete_email.cfm">Delete Email</a>
			</li>
			<li>
				<a href="./trigger_callback.cfm">Trigger Callback</a>
			</li>
		</ul>
		
		<p>
			<a href="./index.cfm?init=true">Log out</a>.
		</p>
		
	</body>
	</html>

</cfoutput>