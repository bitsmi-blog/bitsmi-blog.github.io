---
title: Bitsmi Blog
layout: home
permalink: /
---

{% assign sorted_posts = site.posts | sort:"date" %}

{% for post in sorted_posts reversed %}
## [{{post.title}}]({{ post.url }})

*{{ post.date | date: "%d-%m-%Y" }} - {{post.author}}* 
{: style="font-size: 1.25rem" }

{{post.excerpt}}
[more...]({{ post.url }})

{% endfor %}