---
title: Assertj
layout: page
---

{% assign posts = site.categories["testing"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'assertj'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  