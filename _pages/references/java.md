---
title: Java
author: Antonio Archilla
date: 2025-02-08
layout: post
---

* Do not remove this line (it will not be displayed)
{:toc}

## General guides

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories.size == 2" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Application Servers

### OC4J

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'application servers' and post.categories contains 'oc4j'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Weblogic

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'application servers' and post.categories contains 'weblogic'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Build Tools

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'build tools'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Error Reference

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'error reference'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## JDK

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jdk'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## JVM

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jvm'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## IDE

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'ide'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Libraries

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'libraries'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## Persistence

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'persistence'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

## XML

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'xml'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
