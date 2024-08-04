---
title: Reference & Utilities
author: Antonio Archilla
date: 2024-04-21
layout: post
---

## Database

### Oracle

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'database' and post.categories contains 'oracle'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------

## DevOps

### Monitoring

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'devops' and post.categories contains 'monitoring'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------

## Java

### Build Tools

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'build tools'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Error Reference

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'error reference'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### JVM

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jvm'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
  
[//]: #---------------------------
  
## SCM
  
### Scripts and Utilities

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'scm' and post.categories contains 'scripts and utilities'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------
  
## System
  
### Scripts and Utilities

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'system' and post.categories contains 'scripts and utilities'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------

## Virtualization

### Docker

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'virtualization' and post.categories contains 'docker'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Vagrant

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'virtualization' and post.categories contains 'vagrant'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------
