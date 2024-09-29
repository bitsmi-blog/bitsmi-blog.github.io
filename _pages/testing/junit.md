---
title: JUnit
author: Antonio Archilla
date: 2024-09-29
layout: post
---

{% assign posts = site.categories["testing"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'junit'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  