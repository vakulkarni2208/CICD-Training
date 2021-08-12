({    
	doInit : function(component, event, helper) {                
        var action = component.get("c.getNVContacts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstNV",response.getReturnValue());
                console.log(response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action); 
        
        var action1 = component.get("c.getContactUsData");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contactUsData",response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action1); 
    },
    
    handleClick : function(component, event, helper) {
		var buttonName = event.getSource().get("v.name");
        var AAQ = component.find("AAQid");
        var LASR = component.find("LASRid");
        var TRG = component.find("TRGid");
        if(buttonName == "AAQbtn") {
			$A.util.removeClass(LASR, "show");
            $A.util.removeClass(TRG, "show");
        	$A.util.toggleClass(AAQ, "show");            
        } else if(buttonName == "LASRbtn") {
            $A.util.removeClass(AAQ, "show");
            $A.util.removeClass(TRG, "show");
            //$A.util.toggleClass(LASR, "show");  
            //window.open("/ESPCommunity/s/","_blank");
            window.open($A.get("$Label.c.NPNHomePage_ESPCommunity_URL"),"_blank");
        } else if(buttonName == "TRGbtn") {
            $A.util.removeClass(AAQ, "show");
            $A.util.removeClass(LASR, "show");
            $A.util.toggleClass(TRG, "show");            
        }

	},
    
    sendEmail : function(component, event, helper) {
        var allValid = component.find('emailAAQId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);       
        if (allValid) {
            var fileInput = component.find("fileAAQ").getElement();
    		var file = fileInput.files[0];
            if(file != null) {
            	var saveFn = component.get('c.saveAAQ');
        		$A.enqueueAction(saveFn);    
            } else {
                var action = component.get("c.sendEmail_askAQuestion");
                console.log(component.get("v.contactUsData.objAskAQuestion",true));
                action.setParams({
                    strCompetency: component.get("v.contactUsData.objAskAQuestion.strCompetency"),
                    emailBody: component.get("v.contactUsData.objAskAQuestion.strQuestion"),
                    emailSubject: component.get("v.contactUsData.objAskAQuestion.strEmailSubject"),
                    strStepsToReproduce: component.get("v.contactUsData.objAskAQuestion.strStepsToReproduce"),
                    attachmentId: null
                });            
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var AAQ = component.find("AAQid");
                        $A.util.removeClass(AAQ, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action); 
            }
        } else {
            alert('Please update the invalid form entries and try again.');
        }
	},    
    
    saveAAQ : function(component) {
        var fileInput = component.find("fileAAQ").getElement();
    	var file = fileInput.files[0];
        if (file.size > 4500000) {
            alert('File size cannot exceed ' + 4500000 + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
            component.set("v.file", file);
            component.set("v.fileContents", fileContents);
            var uploadAction = component.get('c.uploadAAQ');
            $A.enqueueAction(uploadAction);
        };
 
        fr.readAsDataURL(file);
    },
    
    uploadAAQ : function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + 950000);
        // start with the initial chunk
        component.set("v.fromPos", 0);
        component.set("v.toPos", toPos);
        component.set("v.attachId", '');
        var uploadAction = component.get('c.uploadChunkAAQ');
        $A.enqueueAction(uploadAction);
        //this.uploadChunk(component, file, fileContents, fromPos, toPos, '');   
    },
     
    uploadChunkAAQ : function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = component.get("v.fromPos");
        var toPos = component.get("v.toPos");
        var attachId = component.get("v.attachId");
       
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            parentId: component.get("v.contactUsData.objAskAQuestion.strAccountId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        action.setCallback(this, function(a) {         
            component.set("v.attachId",a.getReturnValue());
            component.set("v.fromPos", toPos);
            component.set("v.toPos", Math.min(fileContents.length, fromPos + 950000));
            if (component.get("v.fromPos") < component.get("v.toPos")) {
                var uploadChunkAction = component.get('c.uploadChunkAAQ');
                $A.enqueueAction(uploadChunkAction); 
            } else {
                component.set("v.contactUsData.objAskAQuestion.attachmentId",component.get("v.attachId"));
                var action1 = component.get("c.sendEmail_askAQuestion");
                action1.setParams({
                    strCompetency: component.get("v.contactUsData.objAskAQuestion.strCompetency"),
                    emailBody: component.get("v.contactUsData.objAskAQuestion.strQuestion"),
                    emailSubject: component.get("v.contactUsData.objAskAQuestion.strEmailSubject"),
                    strStepsToReproduce: component.get("v.contactUsData.objAskAQuestion.strStepsToReproduce"),
                    attachmentId: component.get("v.contactUsData.objAskAQuestion.attachmentId")
                });
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var AAQ = component.find("AAQid");
                        $A.util.removeClass(AAQ, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action1);            	
            }
        });
        $A.enqueueAction(action);
    },
    
    sendEmailTRG : function(component, event, helper) {
        var allValid = component.find('emailTRGId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);       
        if (allValid) {
            var fileInput = component.find("fileTRG").getElement();
    		var file = fileInput.files[0];
            if(file != null) {
            	var saveFn = component.get('c.saveTRG');
        		$A.enqueueAction(saveFn);    
            } else {
                var action = component.get("c.sendEmail_TrainingRequest");
                action.setParams({
                    strCompetency: component.get("v.contactUsData.objTrainingRequest.strCompetency"),
                    emailBody: component.get("v.contactUsData.objTrainingRequest.strQuestion"),
                    emailSubject: component.get("v.contactUsData.objTrainingRequest.strEmailSubject"),
                    strStepsToReproduce: component.get("v.contactUsData.objTrainingRequest.strStepsToReproduce"),
                    attachmentId: null
                });            
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var TRG = component.find("TRGid");
                        $A.util.removeClass(TRG, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action); 
            }
        } else {
            alert('Please update the invalid form entries and try again.');
        }
	},    
    
    saveTRG : function(component) {
        var fileInput = component.find("fileTRG").getElement();
    	var file = fileInput.files[0];
        if (file.size > 4500000) {
            alert('File size cannot exceed ' + 4500000 + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
            component.set("v.file", file);
            component.set("v.fileContents", fileContents);
            var uploadAction = component.get('c.uploadTRG');
            $A.enqueueAction(uploadAction);
        };
 
        fr.readAsDataURL(file);
    },
    
    uploadTRG : function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + 950000);
        // start with the initial chunk
        component.set("v.fromPos", 0);
        component.set("v.toPos", toPos);
        component.set("v.attachId", '');
        var uploadAction = component.get('c.uploadChunkTRG');
        $A.enqueueAction(uploadAction);
        //this.uploadChunk(component, file, fileContents, fromPos, toPos, '');   
    },
     
    uploadChunkTRG : function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = component.get("v.fromPos");
        var toPos = component.get("v.toPos");
        var attachId = component.get("v.attachId");
       
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            parentId: component.get("v.contactUsData.objTrainingRequest.strAccountId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        action.setCallback(this, function(a) {         
            component.set("v.attachId",a.getReturnValue());
            component.set("v.fromPos", toPos);
            component.set("v.toPos", Math.min(fileContents.length, fromPos + 950000));
            if (component.get("v.fromPos") < component.get("v.toPos")) {
                var uploadChunkAction = component.get('c.uploadChunkTRG');
                $A.enqueueAction(uploadChunkAction); 
            } else {
                component.set("v.contactUsData.objTrainingRequest.attachmentId",component.get("v.attachId"));
                var action1 = component.get("c.sendEmail_TrainingRequest");
                action1.setParams({
                    strCompetency: component.get("v.contactUsData.objTrainingRequest.strCompetency"),
                    emailBody: component.get("v.contactUsData.objTrainingRequest.strQuestion"),
                    emailSubject: component.get("v.contactUsData.objTrainingRequest.strEmailSubject"),
                    strStepsToReproduce: component.get("v.contactUsData.objTrainingRequest.strStepsToReproduce"),
                    attachmentId: component.get("v.contactUsData.objTrainingRequest.attachmentId")
                });
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var TRG = component.find("TRGid");
                        $A.util.removeClass(TRG, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action1);            	
            }
        });
        $A.enqueueAction(action);
    },
    
	sendLASREmail : function(component, event, helper) {
        var allValid = component.find('emailLASRId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);       
        if (allValid) {
            console.log(component.get("v.contactUsData.objLogASupportRequest"));
            var fileInput = component.find("file").getElement();
    		var file = fileInput.files[0];
            if(file != null) {
            	var saveFn = component.get('c.save');
        		$A.enqueueAction(saveFn);    
            } else {
                var action1 = component.get("c.sendEmail_LogASupportRequest");
                action1.setParams({
                    objLSR: component.get("v.contactUsData.objLogASupportRequest")
                });
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var LASR = component.find("LASRid");
                        $A.util.removeClass(LASR, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action1); 
            }
            
        } else {
            alert('Please update the invalid form entries and try again.');
        }
	},
    
    save : function(component) {
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
        if (file.size > 4500000) {
            alert('File size cannot exceed ' + 4500000 + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
            component.set("v.file", file);
            component.set("v.fileContents", fileContents);
            var uploadAction = component.get('c.upload');
            $A.enqueueAction(uploadAction);
        };
 
        fr.readAsDataURL(file);
    },
    
    upload: function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + 950000);
        // start with the initial chunk
        component.set("v.fromPos", 0);
        component.set("v.toPos", toPos);
        component.set("v.attachId", '');
        var uploadAction = component.get('c.uploadChunk');
        $A.enqueueAction(uploadAction);
        //this.uploadChunk(component, file, fileContents, fromPos, toPos, '');   
    },
     
    uploadChunk : function(component) {
        var file = component.get("v.file");
        var fileContents = component.get("v.fileContents");
        var fromPos = component.get("v.fromPos");
        var toPos = component.get("v.toPos");
        var attachId = component.get("v.attachId");
       
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            parentId: component.get("v.contactUsData.objLogASupportRequest.strAccountId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        action.setCallback(this, function(a) {         
            component.set("v.attachId",a.getReturnValue());
            component.set("v.fromPos", toPos);
            component.set("v.toPos", Math.min(fileContents.length, fromPos + 950000));
            if (component.get("v.fromPos") < component.get("v.toPos")) {
                var uploadChunkAction = component.get('c.uploadChunk');
                $A.enqueueAction(uploadChunkAction); 
            } else {
                component.set("v.contactUsData.objLogASupportRequest.attachmentId",component.get("v.attachId"));
                var action1 = component.get("c.sendEmail_LogASupportRequest");
                action1.setParams({
                    objLSR: component.get("v.contactUsData.objLogASupportRequest")
                });
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert("Email sent successfully");
                        var LASR = component.find("LASRid");
                        $A.util.removeClass(LASR, "show");
                    }
                    else {
                        console.log("Failed with state: " + state);
                    }
                });
                // Send action off to be executed
                $A.enqueueAction(action1); 
            	
            }
        });
    
        $A.enqueueAction(action); 
    },
    
    fireComponentEvent : function(cmp, event) {
        // Get the component event by using the
        // name value from aura:registerEvent
        var cmpEvent = cmp.getEvent("cmpEvent");
        cmpEvent.setParams({
            "isOpenAtt" : false });
        cmpEvent.fire();
    },
    
     openModel: function(component, event, helper) {
     	// for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
     },
 
     closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
       // component.set("v.isOpen", false);
    	var closeEvent = component.get('c.fireComponentEvent');
        $A.enqueueAction(closeEvent);
     },
 
     likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        component.set("v.isOpen", false);
     }
           
})