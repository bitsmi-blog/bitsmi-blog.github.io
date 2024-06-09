---
title: Reference & Utilities
author: Antonio Archilla
date: 2024-04-21
layout: post
---

## DevOps

### Monitoring

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'devops' and post.categories contains 'monitoring'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Java

### Build Tools

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'build tools'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### JVM

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jvm'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
  
## SCM
  
### Scripts and Utilities

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'scm' and post.categories contains 'scripts and utilities'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
  
## System
  
### Scripts and Utilities

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'system' and post.categories contains 'scripts and utilities'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}