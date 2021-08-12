({
    myAction : function (component, event, helper) {
    },
    
    dashboardButtonClick : function(component, event, helper) {                      
        window.open(event.getSource().get("v.name"),'_blank');
    },
    
    headerButtonClick : function(component, event, helper) {                      
        window.open(event.getSource().get("v.name"),'_blank');
    },
    
    handleSearch : function (component, event, helper) {
    	if (event && event.keyCode == 13){         
            component.set("v.searchText", component.find("enter-search").get("v.value"))
            component.set("v.isSearchResultPopUpOpen", true); 
            
            console.log('v.searchText'+component.get("v.searchText"));
            console.log(component.find("enter-search").get("v.value"));
        }
    },
    
    doInit: function(component, event, helper) {    	
        var action = component.get("c.getInitializationData");
        action.setCallback(this, function(response) {
            console.log(response.getError());
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.objID", response.getReturnValue());
				var checkBrowserFn = component.get('c.checkBrowser');
        		$A.enqueueAction(checkBrowserFn);   
                /*window.setTimeout(
                    $A.getCallback(function() {
                        var aTags = document.getElementsByTagName("a");
                        console.log(aTags.length);
                        for (var i=0; i < aTags.length; i++) {
                            var aTag = aTags[i];
                            aTag.target = "_blank";
                        	console.log(aTag.getAttribute("href"));
                        }
                        var carouselDiv = document.getElementById("CarouselDiv");
                        console.log(carouselDiv.innerHTML);
                    }), 5000
                );*/               
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    },        
    
   logout : function(component, event, helper) {        
       var menuValue = event.detail.menuItem.get("v.value");
       switch(menuValue) {
       //switch event.get("value") {
           case "logout" : window.location.replace("https://npncommunity.force.com/secur/logout.jsp");
       }
    },
    
    headerSelection : function(component, event, helper) {        
        var menuValue = event.detail.menuItem.get("v.value");
        window.location.href = menuValue;
    },
    
    openModel: function(component, event, helper) {
     	// for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    handleComponentEvent : function(cmp, event) {
        var isOpenAtt = event.getParam("isOpenAtt");

        // set the handler attributes based on event data
        cmp.set("v.isOpen", isOpenAtt);       
        cmp.set("v.isSearchResultPopUpOpen", isOpenAtt); 
    },
    
    checkBrowser: function (component) {
        var browserType = navigator.sayswho= (function(){
            var ua= navigator.userAgent, tem,
                M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if(/trident/i.test(M[1])){
                tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
                return 'IE '+(tem[1] || '');
            }
            if(M[1]=== 'Chrome'){
                tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
                if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
            }
            M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
            if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
            return M.join(' ');
        })();
        if (browserType.startsWith("IE")) {
            document.getElementById("CarouselDiv").style.display = "none";
            document.getElementById("IEMessages").style.display = "block";
        }
    }
    
})