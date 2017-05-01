---
layout: wmt/default
title: Our Blog
---

<div class="row blog-page">
  <div class="col-md-2"><img src="/assets/wmt/img/icons/internal/icon-blog.png" class="img-responsive" alt="blog"/></div>
  <div class="col-md-8">
    {% include wmt/breadcrumbs.html %}
    <h1>{{ page.title }}</h1>
    <p>A vibrant project needs to share news, events, releases and other topics. The blog is the place to follow. 
    And below are some example posts. The source for each post is located in <code>_posts</code>. </p>
  </div>
  <div class="col-md-2"></div>
</div>
    
<div class="row blog-page">
  <div class="col-md-2"></div>
  <div class="col-md-8">
    
    {% for post in site.posts limit: 10 %}
    <div class="blog">
      <h2><a href="{{ post.url }}">{{post.title}}</a></h2>
      <p>{% for author in post.authors %}
         {% assign current = site.authors[author] %}
              <a href="{{ current.web }}">{{ current.name }}</a>
              {% unless forloop.last %}
              ,
              {% endunless%}
         {% endfor %}
      </p>
      <div class="blog-post-tags">
        <ul class="list-unstyled list-inline blog-info blog-tags">
          <li><i class="icon-calendar" style="display:none;"></i> {{ post.date | date_to_string }}</li>
        </ul>
      </div>
      {{ post.excerpt }}
      <div class="blog-readmore"><a href="{{ post.url }}">Read More</a></div>
    </div>
    <div class="clearfix"></div>    
    {% endfor %}
    
    <p><a href="./archive.html">Older Posts in the Archive</a></p>
  </div>
  <div class="col-md-2"></div>
</div>
