<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="org.n52.wps.webadmin.ConfigUploadBean"%>
<%@ page import="org.n52.wps.webadmin.ChangeConfigurationBean"%>
<!DOCTYPE PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<jsp:useBean id="fileUpload" class="org.n52.wps.webadmin.ConfigUploadBean" scope="session" />
<jsp:useBean id="changeConfiguration" class="org.n52.wps.webadmin.ChangeConfigurationBean" scope="session" />
<jsp:setProperty name="changeConfiguration" property="*" />

<% fileUpload.doUpload(request); %>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>WPS Web Admin</title>

	<link type="text/css" rel="stylesheet" href="css/ui.all.css" media="screen">
	<link type="text/css" rel="stylesheet" href="css/lightbox-form.css">
	
	<script type="text/javascript"	src="resources/lightbox-form.js"></script>
	<script type="text/javascript"	src="resources/jquery.js"></script>
	<script type="text/javascript"	src="resources/jquery-ui.js"></script>
	<script type="text/javascript" 	src="resources/jquery.ajax_upload.js"></script>
	
	<script type="text/javascript"><!--
            // constants
            var itemListTypes = new Array("Generator","Parser","Repository");
            var itemListTypeNr = {"Generator":0,"Parser":1,"Repository":2};
            var relativeConfigPath = "../config/";
            var configurationFileName = "wps_config.xml";
            
            // upload req
            var uploadId = "";

            // at page load
            $(document).ready(function(){
                
                $("#Tabs > ul").tabs();
                $("#sections").accordion({
                    header: "div.accHeader",
                    fillSpace: false
                });

                new Ajax_upload('#upload_button', {
                  // Location of the server-side upload script
                  action: 'index.jsp',
                  // File upload name
                  name: 'userfile',
                  // Additional data to send
                  //data: {
                  //  example_key1 : 'example_value',
                  //  example_key2 : 'example_value2'
                  //},
                  // Fired when user selects file
                  // You can return false to cancel upload
                  // @param file basename of uploaded file
                  // @param extension of that file
                  onSubmit: function(file, extension) {
                  },
                  // Fired when file upload is completed
                  // @param file basename of uploaded file
                  // @param response server response
                  onComplete: function(file, response) {
                      loadConfiguration(relativeConfigPath + "<%=fileUpload.getFilenamePrefix()%>" + file);
                  }
                });
                
               	
                $("#upload_process").click(function(){
                    openbox('Upload a WPS process', 1)             
                });

                $("#loadConfBtn").click(function(){
                    loadConfiguration(relativeConfigPath + configurationFileName);
                });

                $("#saveConfBtn").click(function(){
					// check if there are "unsaved" properties, beause they can contain empty data
                	if($("img#saveEditImg").length > 0){
                		alert("There are unsaved properties, please save or delete them.");
					} else {						
	                    if (confirm("Save and Activate Configuration?")) {
	                        $("input[name='serializedWPSConfiguraton']:first").val($("#form1").serialize());
	                        $("#saveConfogurationForm").submit();
	                    }
				    }
                });
                setTimeout
                loadConfiguration(relativeConfigPath + configurationFileName);
            });          
            
            function uploadFiles() {
	          	var uploadCheck = new Boolean(false);
	            var extA = document.getElementById("processFile").value;
	            var extB = document.getElementById("processDescriptionFile").value;
		  			extA = extA.substring(extA.length-3,extA.length);
		  			extA = extA.toLowerCase();
		  			extB = extB.substring(extB.length-3,extB.length);
		  			extB = extB.toLowerCase();
	 			
				if(extA != 'ava' & extA != 'zip' | extB != 'xml' & extB != '')
	  			{
		  			if (extA != 'ava' & extA != 'zip')
	  				{
		  				alert('You selected a .'+extA+ ' file containing the process; please select a .java or .zip file instead!');
	  				if (extB != 'xml' & extB != '') alert('You also selected a .'+extB+ ' file containing the process description; please select a .xml file instead!');
	  				}
	  				else{
		  				alert('You selected a .'+extB+ ' file containing the process description; please select a .xml file instead!');}
	  				uploadCheck=false;
	  			}
	  			else {
	  				uploadCheck=true;
	  			}
				
	  			if (uploadCheck)
	  			{
		  			appendProcessToList();
		  			$("input[name='serializedWPSConfiguraton']:first").val($("#form1").serialize());
		            $("#saveConfogurationForm").submit();
		            return true;
	            }
		  		return false;
           	}
            

            function loadConfiguration(configFile){
                // ensure not getting cached version
                var confFile = configFile + "?" + 1*new Date();

                $.get(confFile,{},function(xml){
                    var hostname = $("Server:first",xml).attr("hostname");
                    var hostport = $("Server:first",xml).attr("hostport");
                    var includeDataInputsInResponse = $("Server:first",xml).attr("includeDataInputsInResponse");
                    var computationTimeoutMilliSeconds = $("Server:first",xml).attr("computationTimeoutMilliSeconds");
                    var cacheCapabilites = $("Server:first",xml).attr("cacheCapabilites");
                    var webappPath = $("Server:first",xml).attr("webappPath");
                    
                    $("#Server_Settings input[name='Server-hostname']:first").val(hostname);
                    $("#Server_Settings input[name='Server-hostport']:first").val(hostport);
                    $("#Server_Settings input[name='Server-includeDataInputsInResponse']:first").val(includeDataInputsInResponse);
                    $("#Server_Settings input[name='Server-computationTimeoutMilliSeconds']:first").val(computationTimeoutMilliSeconds);
                    $("#Server_Settings input[name='Server-cacheCapabilites']:first").val(cacheCapabilites);
                    $("#Server_Settings input[name='Server-webappPath']:first").val(webappPath);

                    // display all algorithm repositories, parsers and generators
                    for (itemType in itemListTypes ){					// "Generator" / "Parser" / "Repository"
                        var listType = itemListTypes[itemType]
                        $("#"+listType+"_List").empty();				// clear the old entries
                        $(listType,xml).each(function(i) {
                            nameEntry = $(this).attr("name");
                            className = $(this).attr("className");
                            activeString = $(this).attr("active");
                            
                            var active = true;
                            if(activeString == "false"){
								active = false;
                            }    
                            
                            var itemID = addListItem(listType);
                            if (nameEntry == "UploadedAlgorithmRepository"){setUploadId(itemID);}

                            // now that the list item exists, add name, class and active to the elements
                            $("#" + listType + "-" + itemID + "_NameEntry").val(nameEntry);					// set the name entry 
                            $("#" + listType + "-" + itemID + "_ClassEntry").val(className);				// set the class entry
                            $("#" + listType + "-" + itemID + "_Activator").attr('checked', active);		// set the active state
                            
                            $('Property',this).each(function(j) {
                                propertyName = $(this).attr("name");
                                propertyValue = $(this).text();
                                propActiveString = $(this).attr("active");

                                var propActive = true;
                                if(propActiveString == "false"){
                                	propActive = false;
                                }   
                                
                                var propID = addPropItem(listType + "-" + itemID + '_Property');

                                // now that the property items exist, add name, value and active state
                                $("#" + listType + "-" + itemID + "_Property" + "-" + propID + "_Name").val(propertyName);
                                $("#" + listType + "-" + itemID + "_Property" + "-" + propID + "_Value").val(propertyValue);
                                $("#" + listType + "-" + itemID + "_Property" + "-" + propID + "_Activator").attr('checked', propActive);
                            });
                        });
                    }
                });
            }

            function addListItem(itemType) {         
                var id = document.getElementById("id").value;
                $("#"+itemType+"_List").append
                (
	                "<p class=\"listItem\" id=\"" + itemType + "-" + id + "\">" +
						"<img src=\"images/del.png\" onClick=\"removeList('"+ itemType + "-" + id + "')\" />"+
						"<table class=\"nameClass\">"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Name</td><td><input type=\"text\" name=\"" + itemType + "-" + id + "_Name\" id=\"" + itemType + "-" + id + "_NameEntry\" /></td></tr>"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Class</td><td><input type=\"text\" name=\"" + itemType + "-" + id + "_Class\" id=\"" + itemType + "-" + id + "_ClassEntry\" /></td></tr>"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Active</td><td><input type=\"checkbox\" name=\"" + itemType + "-" + id + "_Activator\" id=\""+ itemType + "-" + id + "_Activator\" style=\"width:0\" /></td></tr>"+							
						"</table>"+
	         
		                "<br>" +

		                "Properties <img id=\"minMax\" src=\"images/maximize.gif\" onClick=\"maximize_minimize('" + itemType + "-" + id + "'); return false;\" style=\"padding-left:3em;\" style=\"cursor:pointer\" />"+ 
						"<div id=\"maximizer-"+ itemType + "-" + id + "\" style=\"display:none;\">"+
			                "<div class=\"propList\" id=\""+ itemType + "-" + id +"_Property_List\">" +
				                "<div class=\"propListHeader\">" +
					                "<label class=\"propertyNameLabel\" style=\"font-weight:bold;color:black;\">Name</label>" +
					                "<label class=\"propertyValueLabel\" style=\"font-weight:bold;color:black;\">Value</label>" +					                
				                "</div>" +
			                "</div>" +
			                "<div class=\"propEnd\"><img onClick=\"addNewPropItem('" + itemType + "-" + id + "_Property'); return false;\" src=\"images/add.png\" alt=\"Add\" style=\"cursor:pointer\" /></div>"+
			            "</div>"+
	                "</p>"
                );
                var newId = (id - 1) + 2;
                document.getElementById("id").value = newId;
                return id;
            }

            function addNewListItem(itemType) {         
                var id = document.getElementById("id").value;
                $("#"+itemType+"_List").append
                (
	                "<p class=\"listItem\" id=\"" + itemType + "-" + id + "\">" +
	                	"<img src=\"images/del.png\" onClick=\"removeList('"+ itemType + "-" + id + "')\" />"+
						"<table class=\"nameClass\">"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Name</td><td><input type=\"text\" name=\"" + itemType + "-" + id + "_Name\" id=\"" + itemType + "-" + id + "_NameEntry\" style=\"border:1px solid black;background-color:#F5F8F9;\" /></td></tr>"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Class</td><td><input type=\"text\" name=\"" + itemType + "-" + id + "_Class\" id=\"" + itemType + "-" + id + "_ClassEntry\" style=\"border:1px solid black;background-color:#F5F8F9;\" /></td></tr>"+
							"<tr><td style=\"font-weight:bold; padding-right:15px\">Active</td><td><input type=\"checkbox\" name=\"" + itemType + "-" + id + "_Activator\" id=\""+ itemType + "-" + id + "_Activator\" checked style=\"width:0\" /></td></tr>"+							
						"</table>"+
	         
		                "<br>" +

		                "Properties <img id=\"minMax\" src=\"images/maximize.gif\" onClick=\"maximize_minimize('" + itemType + "-" + id + "'); return false;\" style=\"padding-left:3em;cursor:pointer;\" />"+ 
						"<div id=\"maximizer-"+ itemType + "-" + id + "\" style=\"display:none;\">"+
			                "<div class=\"propList\" id=\""+ itemType + "-" + id +"_Property_List\">" +
				                "<div class=\"propListHeader\">" +
					                "<label class=\"propertyNameLabel\" style=\"font-weight:bold;color:black;\">Name</label>" +
					                "<label class=\"propertyValueLabel\" style=\"font-weight:bold;color:black;\">Value</label>" +					                
				                "</div>" +
			                "</div>" +
			                "<div class=\"propEnd\"><img onClick=\"addNewPropItem('" + itemType + "-" + id + "_Property'); return false;\" src=\"images/add.png\" alt=\"Add\" style=\"cursor:pointer\" /></div>"+
			            "</div>"+
	                "</p>"
                );
                var newId = (id - 1) + 2;
                document.getElementById("id").value = newId;
                return id;
            }

            function removeList(id){
            	$("p#" + id).remove();
            	$("div#maximizer-" + id).remove();
            }
            
            function maximize_minimize(id){
				var div = $("div#maximizer-" + id);
				if(div.css("display") == "none"){
					div.show("fast");
					$("img#minMax").attr("src","images/minimize.gif");
				} else {
					div.hide("fast");
					$("img#minMax").attr("src","images/maximize.gif");
				}				
            }

            function addPropItem(itemType) {
                var id = document.getElementById("id").value;
                $("#" + itemType + "_List").append
                (
                "<div class=\"propItem\" id=\"" + itemType + "-" + id + "\">"+
                    "<input type=\"text\" class=\"propertyName\" size=\"15\" name=\""+ itemType + "-" + id +"_Name\" id=\"" + itemType + "-" + id + "_Name\" readonly />"+
                    "<input type=\"text\" class=\"propertyValue\" size=\"20\" name=\""+ itemType + "-" + id +"_Value\" id=\""+ itemType + "-" + id + "_Value\" readonly />"+
					"<input type=\"checkbox\" name=\"" + itemType + "-" + id +"_Activator\" id=\"" + itemType + "-" + id +"_Activator\" />" +            
                    "<img onClick=\"removeItem('#"+ itemType + "-" + id + "'); return false;\" src=\"images/del.png\" width=\"16\" height=\"16\" alt=\"Remove\" style=\"cursor:pointer\" />"+
                    "<img id=\"editImg\" onClick=\"edit('#"+ itemType + "-" + id + "'); return false;\" src=\"images/edit.png\" alt=\"Edit\" style=\"cursor:pointer\" />"+
                "</div>"
                );
                var newId = (id - 1) + 2;
                document.getElementById("id").value = newId;
                return id;
            }

            function addNewPropItem(itemType) {
                var id = document.getElementById("id").value;
                $("#" + itemType + "_List").append
                (
                "<div class=\"propItem\" id=\"" + itemType + "-" + id + "\">"+
                    "<input type=\"text\" class=\"propertyName\" size=\"15\" name=\""+ itemType + "-" + id +"_Name\" id=\"" + itemType + "-" + id + "_Name\" style=\"border:1px solid black;background-color:#F5F8F9;\" />"+
                    "<input type=\"text\" class=\"propertyValue\" size=\"20\" name=\""+ itemType + "-" + id +"_Value\" id=\""+ itemType + "-" + id + "_Value\" style=\"border:1px solid black;background-color:#F5F8F9;\" />"+
					"<input type=\"checkbox\" name=\"" + itemType + "-" + id +"_Activator\" id=\"" + itemType + "-" + id +"_Activator\" checked />" +            
                    "<img onClick=\"removeItem('#"+ itemType + "-" + id + "'); return false;\" src=\"images/del.png\" alt=\"Remove\" style=\"cursor:pointer\" />"+
                    "<img id=\"saveEditImg\" onClick=\"saveEdit('#"+ itemType + "-" + id + "'); return false;\" src=\"images/save.png\" alt=\"Save edit\" style=\"cursor:pointer\" />"+
                "</div>"
                );
                var newId = (id - 1) + 2;
                document.getElementById("id").value = newId;
                return id;
            }            

            function removeItemList(listType,id) {
                $("#" + listType + "-" + id).remove();
                $("#" + listType + "-" + id + "_Property_List").remove();
            }

            function removeItem(id) {
                $(id).remove();
            }

            function resetLisings(){
                if (confirm("Reset Form data?")) {
                    for (itemListType in itemListTypes) {
                        $("#"+ itemListTypes[itemListType] +"_List").empty();
                    }
                    return true;
                } else {
                    return false;
                }
            }
                
            function setUploadId(itemID){
             	uploadId = itemID;
            }
                      
			function appendProcessToList() {                            			
				 itemType= "Repository-" + uploadId + "_Property";
				 listName= "Repository-" + uploadId + "_Property_List";
				 var id = document.getElementById("id").value;
				 processNameId = document.getElementById("processNameId").value;
				 algorithmName = "Algorithm";
	             
	             $("#"+listName).append("<div class=\"propItem\" id=\"" + itemType + "-" + id + "\">"+
	                    	"<input class=\"propertyName\" type=\"text\" size=\"15\" name=\""+ itemType + "-" + id +"_Name\" id=\"" + itemType + "-" + id + "_Name\" value=\"" + algorithmName +"\" />"+
	                    	"<input class=\"propertyValue\" type=\"text\" size=\"15\" name=\""+ itemType + "-" + id +"_Value\" id=\""+ itemType + "-" + id + "_Value\" value=\"" + processNameId + "\" />"+
	                   	 	"<img onClick=\"removeItem('#"+ itemType + "-" + id + "'); return false;\" src=\"images/min_icon.png\" width=\"14\" height=\"18\" alt=\"Remove\"/>"+
	                		"</div>");
	
	                
	            var newId = (id - 1) + 2;
	            document.getElementById("id").value = newId;
	            return id;
            }

            function edit(id){
                 // change the css
            	 $(id+"> input").css({	"border":"0.1em solid #4297D7", 
                	 					"background-color":"#F5F8F9"
                 });
				 // remove the readonly attribute
				 $(id+"> input").removeAttr("readonly"); 
                 
                 // append the save button
            	 $(id+" > img#editImg").remove();
            	 $(id).append($("<img id=\"saveEditImg\" onClick=\"saveEdit('"+ id + "'); return false;\" src=\"images/save.png\" alt=\"Save edit\" style=\"cursor:pointer\" />"));            	 
            }

            function saveEdit(id){
            	$(id+"> input").css({	"border":"none",
                						"background-color":"#CDE2ED"
                }); 

            	$(id+"> input").attr("readonly", "readonly"); 
                
            	$(id+" > img#saveEditImg").remove();
            	$(id).append($("<img id=\"editImg\" onClick=\"edit('"+ id + "'); return false;\" src=\"images/edit.png\" alt=\"Edit\" style=\"cursor:pointer\" />"));
            }

            function editServerSettings(){
				// display warnings
				$("div#editWarn").show();
                
                // change the css
	            $("div#Server_Settings input").css({	"border":"0.1em solid #4297D7", 
	               	 									"background-color":"#F5F8F9"
	            });
				// remove the readonly attribute
				$("div#Server_Settings input").removeAttr("readonly"); 
	                
	            // append the save button
	           	$("div#editSave img#editImg").remove();
	           	$("div#editSave").append($("<img id=\"editImg\" onClick=\"saveEditServerSettings(); return false;\" src=\"images/save.png\" alt=\"Save edit\" style=\"cursor:pointer\" />"));            	 				
            }

			function saveEditServerSettings(){
				// hide warnings
				$("div#editWarn").hide();

                // change the css
	            $("div#Server_Settings input").css({	"border":"none",
														"background-color":"#CDE2ED"
	            });
				// remove the readonly attribute
				$("div#Server_Settings input").attr("readonly", "readonly"); 
	                
	            // append the save button
	           	$("div#editSave img#editImg").remove();
	           	$("div#editSave").append($("<img id=\"editImg\" onClick=\"editServerSettings(); return false;\" src=\"images/edit.png\" alt=\"Save edit\" style=\"cursor:pointer\" />"));            	 								
            }

        -->
    </script>
</head>
<body>

	<div style="height: 75px">
		<img style="float: left" src="images/52northlogo_small.png" alt="52northlogo_small" />
		<h1	style="padding-left: 3em; color: #4297d7; font-family: Lucida Grande, Lucida Sans, Arial, sans-serif; font-size: 3em;">Web Admin Console</h1>
	</div>
	<div id="Tabs" class="ui-tabs ui-widget ui-widget-content ui-corner-all">
		<ul>
			<li><a href="#tab-1"><span>WPS Config Configuration</span></a></li>
			<li><a href="#tab-2"><span>WPS Test Client</span></a></li>
		</ul>
		<div id="tab-1">
			<form action="#" method="post" id="saveConfogurationForm">
				<input type="hidden" name="serializedWPSConfiguraton" />
			</form>
			<form action="#" method="get" id="form1" onreset="return resetLisings()">
				<table border="0" cellspacing="0">
					<tr>
						<td><input class="formButtons" id="saveConfBtn" type="button" value="Save and Activate Configuration" name="save" style="border:1px solid black;background:white;" /></td>
						<td><input class="formButtons" id="loadConfBtn" type="button" value="Load Active Configuration" name="load" style="border:1px solid black;background:white;" /></td>
						<td><input class="formButtons" id="upload_button" type="button" value="Upload Configuration File" name="upload" style="border:1px solid black;background:white;cursor:pointer;" /></td>
						<td><input class="formButtons" type="reset" value="Reset" name="Reset" style="border:1px solid black;background:white;" /></td>
						<td><input class="formButtons" id="upload_process" type="button" value="Upload Process" name="UploadProcess" style="border:1px solid black;background:white;" /></td>
					</tr>
				</table>
				<div id="sections">
					<div class="section">
						<div class="accHeader" style="text-indent: 40px">Server Settings</div>
						
						<div class="sectionContent">
							<div id="Server_Settings">
								<div id="editSave" style="float:right;"><img id="editImg" src="images/edit.png" onClick="editServerSettings()" style="cursor:pointer;" /></div>
								<p>
									<label for="Server-hostname">Server Host Name:</label><div id="editWarn" style="float: left;display: none; padding-right: 10px;"><img src="images/warn.png" /> Changes only after restart</div>
									<input type="text" name="Server-hostname" value="testValue" readonly/>
									<br style="clear:left;" />
								</p>
								<p>
									<label for="Server-hostport">Server Host Port:</label><div id="editWarn" style="float: left;display: none; padding-right: 10px;"><img src="images/warn.png" /> Changes only after restart</div>
									<input type="text" name="Server-hostport" value="testValue" readonly/>
									<br style="clear:left;" />
								</p>
								<p>
									<label for="Server-includeDataInputsInResponse">Include Datainput:</label>
									<input type="text" name="Server-includeDataInputsInResponse" value="boolean" readonly/>
								</p>
								<p>
									<label for="Server-computationTimeoutMilliSeconds">Computation Timeout:</label>
									<input type="text" name="Server-computationTimeoutMilliSeconds" value="testValue" readonly/>
								</p>
								<p>
									<label for="Server-cacheCapabilites">Cache Capabilities:</label>
									<input type="text" name="Server-cacheCapabilites" value="boolean" readonly/>
								</p>
								<p>
									<label for="Server-webappPath">Web app Path:</label><div id="editWarn" style="float: left;display: none; padding-right: 10px;"><img src="images/warn.png" /> Changes only after restart</div>
									<input type="text" name="Server-webappPath" value="testValue" readonly/>
									<br style="clear:left;" />
								</p>
								<p></p>
							</div>
						</div>
					</div>
					<div class="section">
						<div class="accHeader" style="text-indent: 40px">Algorithm Repositories</div>
						<div class="sectionContent">
							<input type="hidden" id="id" value="1">
							<div class="lists" id="Repository_List"></div>
							<p class="addListItem">
								<input type="button" value="Add Repository" name="addRepositoryButton" onClick="addNewListItem(itemListTypes[itemListTypeNr.Repository]); return false;" style="border:1px solid black;background:white;" />
							</p>
						</div>
					</div>
					<div class="section">
						<div class="accHeader" style="text-indent: 40px">Parsers</div>
						<div class="sectionContent">
							<div class="lists" id="Parser_List"></div>
							<p class="addListItem">
								<input type="button" value="Add Paser" name="addPaserButton" onClick="addNewListItem(itemListTypes[itemListTypeNr.Parser]); return false;" style="border:1px solid black;background:white;" />
							</p>
						</div>
					</div>
					<div class="section">
						<div class="accHeader" style="text-indent: 40px">Generators</div>
						<div class="sectionContent">
							<div class="lists" id="Generator_List"></div>
							<p class="addListItem">
								<input type="button" value="Add Generator" name="addGeneratorButton" onClick="addNewListItem(itemListTypes[itemListTypeNr.Generator]); return false;"  style="border:1px solid black;background:white;" />
							</p>
						</div>
					</div>
				</div>
			</form>
		</div>
		<div id="tab-2">
			<div style="height: 400px">
				Try the request examples: 
				<a target="_blank" href="../WebProcessingService?Request=GetCapabilities&Service=WPS">GetCapabilities request</a><br><br> 
				WPS TestClient: <br>
				<table>
					<tr>
						<td><b> Server: </b></td>
						<td>
							<form name="form1" method="post" action="">
								<div>
									<input name="url" value="../WebProcessingService" size="90"	type="text">
								</div>
							</form>
						</td>
					</tr>
					<tr>
						<td><b> Request: </b></td>
						<td>
							<form name="form2" method="post" action="" enctype="text/plain">
								<div>
									<textarea name="request" cols="88" rows="15"></textarea>
								</div>
								<input value="   Clear    " name="reset" type="reset"> 
								<input value="   Send    " onclick="form2.action = form1.url.value"	type="submit">
							</form>
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
	
	<!-- upload form -->
	
	<div id="filter"></div>
	<div id="box">
		<span id="boxtitle"></span>
		<form method="post" action="index.jsp" enctype="multipart/form-data" onsubmit="return uploadFiles()">
			<input type="hidden" name="uploadProcess" />
			<p>
				Please enter the fuly qualified name of the java class implementing IAlgorithm:<br>
				<input type="text" name="processName" size="30" id="processNameId">
			</p>
			<p>
				Please specify the .java file for the process:<br>
				<input type="file" name="processFile" id="processFile" size="40">
			</p>
			<p>
				Please specify the associated ProcessDescription .xml file
				(optional):<br>
				<input type="file" name="processDescriptionFile" id="processDescriptionFile" size="40" accept="text/xml">
			</p>
			<p>
				<input type="submit" name="submit"> 
				<input type="reset" name="cancel" value="Cancel" onclick="closebox()">
			</p>
		</form>
	</div>

</body>
</html>