---
title: Wiremock
author: Antonio Archilla
date: 2024-08-25
layout: post
---

{% assign posts = site.categories["testing"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'wiremock'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  