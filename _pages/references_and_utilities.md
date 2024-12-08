---
title: Reference & Utilities
author: Antonio Archilla
date: 2024-04-21
layout: post
---

* Do not remove this line (it will not be displayed)
{:toc}

## Database

### Oracle

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'database' and post.categories contains 'oracle'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### SQL

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'database' and post.categories contains 'sql'" %}
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

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories.size == 2" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Application Servers

#### OC4J

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'application servers' and post.categories contains 'oc4j'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

#### Weblogic

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'application servers' and post.categories contains 'weblogic'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

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

### JDK

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jdk'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### JVM

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'jvm'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### IDE

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'ide'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Libraries

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'libraries'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Persistence

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'persistence'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### XML

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'xml'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------

## Javascript

### ECMA Script

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'javascript' and post.categories contains 'ECMA-script'" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
  
[//]: #---------------------------

## Other

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'other' and post.categories.size == 2" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

### Error Reference

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'other' and post.categories contains 'error reference'" %}
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

### Ubuntu

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'system' and post.categories contains 'ubuntu'" %}
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

## Web

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'web' and post.categories.size == 2" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}

[//]: #---------------------------

## Webservices

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'webservices' and post.categories.size == 2" %}
{% for post in posts %}
- [{{post.title}}]({{post.url}})
{% endfor %}
