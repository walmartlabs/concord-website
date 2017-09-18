function toggleMenu(obj, menuId) {
    $(menuId).toggleClass('hidden');
    if ($(menuId).hasClass('hidden')) {
        $("i", obj).attr('class', 'fa fa-chevron-right pale-blue');
    } else {
        $("i", obj).attr('class', 'fa fa-chevron-down pale-blue');
    }
}
