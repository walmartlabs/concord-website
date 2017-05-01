function toggleMenu(obj, menuId) {
    $(menuId).toggleClass('hidden');
    if ($(menuId).hasClass('hidden')) {
        $("i", obj).attr('class', 'fa fa-caret-right');
    } else {
        $("i", obj).attr('class', 'fa fa-caret-down');
    }
}