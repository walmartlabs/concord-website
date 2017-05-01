---
layout: wmt/default
title: Blog Archive
---

<div class="row blog-page">
  <div class="col-md-2"><img src="/assets/wmt/img/icons/internal/icon-blog.png" class="img-responsive" alt="blog"/></div>
  <div class="col-md-8">
    {% include wmt/breadcrumbs.html %}
    <h1>{{ page.title}}</h1>
  </div>
  <div class="col-md-2"></div>
</div>
    
<div class="row blog-page">
  <div class="col-md-2"></div>
  <div class="col-md-8">

<p>The complete list of posts from the team:</p>

{% for post in site.posts %}
{% assign currentdate = post.date | date: "%Y" %}
{% if currentdate != date %}
<h1 id="y{{currentdate}}">{{ currentdate }}</h1>
{% assign date = currentdate %} 
{% endif %}

<p>
{{ post.date | date: "%-d %B %Y" }}:
<a href="{{ post.url }}">{{ post.title}}</a> by 
{% for author in post.authors %}{% assign current = site.authors[author] %}<a href="{{ current.web }}">{{ current.name }}</a>
{% unless forloop.last %},{% endunless%}
{% endfor %}
</p>

{% endfor %}


  </div>
  <div class="col-md-2"></div>
</div>
