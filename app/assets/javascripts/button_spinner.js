$('.btn').button();

$(document).ready(function () {
    $('.btn').click(function () {
        if ($('#el_scraper_urls').val().length == 0) {
        } else {
            $(this).button('loading');
        }
    });
});
