---
title: Reference & Utilities
author: Antonio Archilla
date: 2024-04-21
layout: post
---

## Java

### Build Tools

{% assign java_build_tools = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'java' and post.categories contains 'build tools'" %}
{% for post in java_build_tools %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
  
  
## System
  
### Scripts and Utilities

{% assign system_utilities = site.categories["references"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'system' and post.categories contains 'scripts and utilities'" %}
{% for post in system_utilities %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}