---
title: Kumo
author: Antonio Archilla
date: 2024-04-27
layout: post
---

{% assign posts = site.categories["project"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'kumo'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  