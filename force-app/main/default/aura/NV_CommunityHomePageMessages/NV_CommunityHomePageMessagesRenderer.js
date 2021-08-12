({
	// Your renderer method overrides go here
	 afterRender : function(component, helper) { 
        this.superAfterRender();
        component.set("v.slideIndex", 1);
        var n = 1;
    	console.log(n);
         var i;
        var slides = document.getElementsByClassName("mySlides");        
        var dots = document.getElementsByClassName("dot");         
        if (n > slides.length) {component.set("v.slideIndex", 1);n = 1;} 
        if (n < 1) {component.set("v.slideIndex", slides.length);n = slides.length; }
        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
        }
        for (i = 0; i < dots.length; i++) {
            dots[i].className = dots[i].className.replace(" active", "");
        }
         console.log(n);
        slides[n-1].style.display = "block";
        dots[n-1].className += " active";
	}
})