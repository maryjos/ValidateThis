<!---
	
	Copyright 2008, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
	
--->
<cfcomponent output="false" name="ServerRuleValidator_Custom" extends="AbstractServerRuleValidator" hint="I am responsible for performing a custom validation.">

	<cffunction name="validate" returntype="any" access="public" output="false" hint="I perform the validation returning info in the validation object.">
		<cfargument name="valObject" type="any" required="yes" hint="The validation object created by the business object being validated." />

		<cfset var customResult = {IsSuccess=false,FailureMessage="A custom validator failed."} />
		<cfset var theObject = arguments.valObject.getTheObject() />
		<cfset var Parameters = arguments.valObject.getParameters() />
		<cfset var theMethod = Parameters.MethodName />
		<cfset var methodExists = false />
		
		
		<!--- Note: isInstanceOf() is being used to identify Groovy or Java objects, 
			the existence of whose methods can not be checked via structKeyExists().
			The problem with this approach is that if a method does not exist in a Java/Groovy object, 
			no error will be thrown. The validator will simply fail.
			This should be addressed in a future version --->
		<cfif variables.ObjectChecker.isCFC(theObject)>
			<cfset methodExists = StructKeyExists(theObject,theMethod)>			
		<cfelse>
			<cfset methodExists = true />
		</cfif>
		<cfif methodExists>
			<!--- Using try/catch to deal with methods that might not exist in Java/Groovy objects --->
			<cftry>
				<cfset customResult = evaluate("theObject.#theMethod#()") />
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfif NOT IsDefined("customResult")>
				<cfset customResult = {IsSuccess=false,FailureMessage="A custom validator failed."} />
			</cfif>
			<cfif NOT customResult.IsSuccess>
				<cfset fail(arguments.valObject,customResult.FailureMessage) />
			</cfif>
		<cfelse>
			<cfthrow type="validatethis.server.ServerRuleValidator_Custom.methodNotFound"
					message="The method #theMethod# was not found in the object passed into the validation object." />
		</cfif>
	</cffunction>

</cfcomponent>
	
