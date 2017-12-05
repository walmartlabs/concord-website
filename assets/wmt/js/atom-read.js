function atomRead(feedUrl, divId) {
  $.get(feedUrl, function(data) {
    var $XML = $(data);
    $XML.find("entry").each(function() {
      var $this = $(this),
          item = {
              title: $this.find("title").text(),
              url: $this.find("link").attr('href'),
              date: $this.find("updated").text()
          };
     var blog = "<a href=\"" + item.url + "\">" + item.title + "</a> | " + item.date + "<br><br>";
      $('#' + divId).append(blog);
    });
  });
};
