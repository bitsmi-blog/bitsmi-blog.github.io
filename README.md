# BitSmi Blog

## Build site and execute in local environment

### Prerequisites

- Have `Docker Daemon` or `Docker Desktop` installed

### Container creation

Execute the following script to create the required `Jekyll` Docker container

```sh
docker-serve.bat
```

After that, the container can be started / stopped using regular `docker container start / stop` commands or from `Docker Desktop`. Site should be accessible at `http://localhost:4000`

### Site build

After `Jekyll container` is created, you can build the site from sources executing the following command. This is only needed if there are changes made after container creation as 
`docker-serve` script also builds the site as a previous step to create the container.

```sh
docker-build.bat
```

## How-tos

### Create a new category index page in side menu

- Create a new page `*.md` file for the category inside `_pages` repository root folder. If the category is nested within multiple levels, create the whole folder structure until reach leaf category. 
For example, for the category `spring` > `dependency injection` you should create the following file `_pages/spring/dependency_injection.md`.
- Create a minimal front matter content putting page's **title**, **author** and **date** as first content of the file. For example:
```
---
title: Page title
author: Page author
date: Page date in YYYY-MM-DD format
layout: post
---
```
- Write down the following content after the fron matter to list all post for a set of categories (replace `category1` and `category2` for the required ones)
```
{% assign posts = site.categories["category_1"] | sort:"title" | where_exp:"post", "post.url and post.categories contains 'category_2'" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
```
For single level categories the snippets is a bit different:
```
{% assign posts = site.categories["category"] | sort:"title" %}
{% for post in posts %}
- [**{{post.title}}**]({{post.url}})
{% endfor %}
``` 
- Edit `_data/sidebar/menu.json` file to include the new category page in the list as parent - child structure. For example:
```json
{
	"title": "Category 1",
	"children": [
		{
			"title": "Page title",
			"url": "/pages/category_1/category_2/"
		}
	]
},
```
Only leaf nodes have an `url` pointing to the respective page.

### Create a new Post

- Create (if doesn't exists) a folder inside `_posts` project's root folder for the category under the post will be classified. 
- If you want to create a draft so the post is not took into account when the site is built, place in `_drafts` folder instead. It can be moved later to `_posts` when it is finished.
  For example, if you want to create a new post under categories `Spring` > `Dependency Injection`, post file will be placer under `_posts/spring/dependency_injection` folder.
- Create the post file using the following pattern for its filename `<date>-<name_of_the_post>.<ext>`, where
	- `<date>` is post publication date in `YYYY-MM-DD` format
	- `<name_of_the_post>` should be a descriptive name for the file. It should have relation with post title specified inside the file but it doesn't to be the same.
	  It is recommended to use `_` as word separator and do not use special characters like accented vowels, `ñ`, `ç`...
	- Post can be written using **Markdown** (in a `*.md` file) or **Asciidoc** (in a `*.adoc` file)
- Set post metadata in front matter specifying posts **author name**, **title**, **publication date**, **categories** and **tags**. Write the following snippet as the first file content:
```
---
author: Author name
title: Post title
date: 2099-01-01
categories: [ "category1", "category2" ]
tags: [ "tag1", "tag2" ]
layout: post
excerpt_separator: <!--more-->
---
```
- Post attached assets should be placed inside `/assets/posts` folder in this repository. Create a nested folder following the same folder structure from `/_posts` folder and name the asset
  following the pattern `<post filename>_fig<N>.<ext>` for figures. If a post has several assets, you can create a subfolder with post filename and place all assets there using only the `fig<N>.<ext>`identifier. To create a link in a `*.md` post to the asset you can use the following statement
  ```
  ![](/assets/posts/path/to_asset.ext)
  ```
- Build site to include changes using `docker-build.bat` command and check changes in the local running container at `http://localhost:4000`
