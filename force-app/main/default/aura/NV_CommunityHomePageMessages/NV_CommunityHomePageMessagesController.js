({
    plusSlides : function(component, event, helper) {
        component.set("v.slideIndex", 1)
        var a = component.get('c.showSlides');
        $A.enqueueAction(a);
        showSlides(slideIndex += n);
    },
    currentSlide : function(component, event, helper) {
        showSlides(slideIndex = n);
    },
 	showSlides : function(component, event, helper) {        
        console.log('test'); 
        var n = component.get("v.slideIndex");
    	var i;
        var slides = document.getElementsByClassName("mySlides");
        var dots = document.getElementsByClassName("dot");
        if (n > slides.length) {slideIndex = 1} 
        if (n < 1) {slideIndex = slides.length}
        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none"; 
        }
        for (i = 0; i < dots.length; i++) {
            dots[i].className = dots[i].className.replace(" active", "");
        }
        slides[slideIndex-1].style.display = "block"; 
        dots[slideIndex-1].className += " active";
    }
})