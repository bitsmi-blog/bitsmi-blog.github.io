---
title: Spring Dependency Injection
author: Antonio Archilla
date: 2024-09-29
layout: post
---

{% assign posts = site.categories["spring"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'validation'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  