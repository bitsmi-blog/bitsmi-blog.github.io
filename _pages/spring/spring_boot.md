---
title: Spring Boot
author: Antonio Archilla
date: 2024-10-27
layout: post
---

{% assign posts = site.categories["spring"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'spring-boot'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  