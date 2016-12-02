$('.btn').button();

$(document).ready(function () {
    $('.btn').click(function () {
        $(this).button('loading');
        //$(this).button('reset');
    });
});
