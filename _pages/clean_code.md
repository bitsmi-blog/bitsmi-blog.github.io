---
title: Clean Code
author: Xavier Salvador
date: 2025-02-08
layout: post
---

{% assign posts = site.categories["clean_code"] | sort:"title" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
