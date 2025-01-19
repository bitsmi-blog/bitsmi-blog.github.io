---
title: Patterns
author: Antonio Archilla
date: 2025-01-19
layout: post
---

{% assign posts = site.categories["spring"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'patterns'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  