---
title: Other
layout: page
---

* Do not remove this line (it will not be displayed)
{:toc}

## DevOps

### Monitoring

{% assign posts = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'devops' and post.categories contains 'monitoring'" %}
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
