---
title: Clean Code
layout: page
---

{% assign posts = site.categories["clean_code"] | sort:"page_order" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
