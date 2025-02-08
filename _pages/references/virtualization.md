---
title: Virtualization
author: Antonio Archilla
date: 2025-02-08
layout: post
---

## Docker

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'virtualization' and post.categories contains 'docker'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Vagrant

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'virtualization' and post.categories contains 'vagrant'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
