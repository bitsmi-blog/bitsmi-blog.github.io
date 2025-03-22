---
title: Database
layout: page
---

## Oracle

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'database' and post.categories contains 'oracle'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## SQL

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'database' and post.categories contains 'sql'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
