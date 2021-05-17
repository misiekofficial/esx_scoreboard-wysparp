$(function()
{
    window.addEventListener('message', function(event)
    {
		var buf = $('#wrap');

        var item = event.data;
        if (item.data)
        {
			buf.find('table').append("<h1 class=\"heading\">WyspaRP.pl</h1><img class='image' src='img.png'><p id='website'>https://forum.wyspa.gg</p><p id='discord'>https://wyspa.gg</p><p id='duties'>" + item.duties + "</p>");
			buf.find('table').append(item.data);
			if (item.admin) {
				buf.addClass('admin');
			}
			buf.show();
		} else {
            document.getElementById("ptbl").innerHTML = "";
			buf.removeClass('admin');
            buf.hide();
        }
    }, false);
});