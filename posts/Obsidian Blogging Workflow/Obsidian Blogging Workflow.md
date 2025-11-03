---
tags:
- blog-post
- blogging
- C
- GoLang
- GitHub
- Hugo
- Git
- Python
date: 2025-10-15
title: 'Blogging: Obsidian to Hugo Workflow'
draft: false
---

# Summary

This is my first blog post and im going to talk about how to make an easy workflow between Obsidian and [Hugo](https://gohugo.io/). I love using [Obsidian](https://obsidian.md/) and I love taking Notes, now its time to share them with the rest of the Internet. The approach I take is a three stage approach, which is outlined in the diagram below. We will walk our way through this workflow in this blog and outline the tools and the stages as we go through.

[Fixing Obsidian Links for Hugo](./posts/Fixing Obsidian Links for Hugo/Fixing Obsidian Links for Hugo.md)
# What tools will you need?

This is my first blogpost and im going to talk about how to make an easy workflow between Obsidian and [Hugo](https://gohugo.io/). I love using [Obsidian](https://obsidian.md/) and I love taking Notes, now its time to share them with the rest of the Internet. The approach I take is a three stage approach, which is outlined in the diagram below. We will walk our way through this workflow in this blog and outline the tools and the stages as we go through.

## What tools will you need?

The tools and languages you will need during this blog are shown below:

- [[git]] - versioning your blogs and Obsidian Notes
- [GitHub](https://github.com/ScottGibb) - Hosting your Repositories and publishing your [Hugo](https://gohugo.io/) Blog
- [[Markdown]] - The file format of your blogs
- [Hugo](https://gohugo.io/) - Turning your Markdown files into beautiful Web code (JavaScript, css, html)
  - [GoLang](https://golang.org/) - The language used to create the Static Site Generator

## The Project Structure

Before we go into the different stages of the workflow. Its best to first discuss the repository structure we are using. I have the following repositories

- Gibb Knowledge Base - A private repository that contains my personal notes and is self hosted. This is where all my notes are stored and managed using Obsidian. I often link my posts to notes in here. However these links will not work on the published site.
- [Gibbiverse Content](https://github.com/ScottGibb/blog-posts)- A public repository that contains my blog posts in markdown format. This doesn't contain any specific Hugo files, it primarily consists of Markdown and images. No code is added here or project configuration. There is some [[GitHub Actions]]
- added to allow [MegaLinter](https://megalinter.io/latest/) to run and check the formatting.
- [Gibbiverse](https://github.com/ScottGibb/Gibbiverse) - A public repository that contains the Hugo site. This is where the configuration of the site and theme settings are stored. There are also another set of [[GitHub Actions]] this time targeting the build and deploy process with [[GitHub Pages]].
- [Gibbiverse Link Fixer](https://github.com/ScottGibb/Gibbiverse) - A public repository that contains a [Python](https://www.python.org/) application which is designed to replace the links inside the content so that the content renders correctly in [Hugo](https://gohugo.io/).

This whole structure allows me to continue using [Obsidian](https://obsidian.md/) to write content and link to my personal notes and vice versa, enhancing the Second Brain nature that [Obsidian](https://obsidian.md/) provides.

# The Stages

Before we dive deep into the technicalities of the process. It's best to first give an overview of the different stages and then we can highlight what the issues were and how they were overcome

## The Stages

Before we dive deep into the technicalities of the process. Its best to first give an overview of the different stages and then we can highlight what the issues were and how they were overcome.

The workflow can be seen below in the following #excalidraw diagram:

![Obsidian Blog Workflow.excalidraw](Obsidian%20Blog%20Workflow.excalidraw.svg)

## Stage 1: Writing your Blog

In this stage you make notes as usual and write your blog posts. The way in which I do this is by having a dedicated folder in my Obsidian Vault called `Blog`. This is where all my blog posts are written. I regularly push these notes to the `Gibbiverse Content` repository. I can write offline on my travels and grab inspiration from the Obsidian Vault in a quick glance.

Typically I work out of a branch per blog as this allows me to run [[GitHub Actions]] specifically [MegaLinter](https://megalinter.io/latest/) which catches out formatting errors and spelling errors. I can also run  [[GitHub Agents]] to check over my work and improve my writing style

Typically I work out of a branch per blog as this allows me to run [[GitHub Actions]] specifically [MegaLinter](https://megalinter.io/latest/) which catches out formatting errors and spelling errors. I can also run  [[GitHub Agents]] to check over my work and improve my writing style.

At this stage, most of the work is being done as it's focused on creating the blog itself and the content alongside some of the formatting

### Stage 1: [Obsidian](https://obsidian.md/)

In this stage you make notes as usual and write your blog posts. The way in which I do this is by having a dedicated folder in my Obsidian Vault called `Blog`. This is where all my blog posts are written. I regularly push these notes to the `Gibbiverse Content` repository. I can write offline on my travels and grab inspiration from the Obsidian Vault in a quick glance.

## Stage 2: Seeing the Final Content

In Stage 2 we create a new branch in the [Gibbiverse](https://github.com/ScottGibb/Gibbiverse) repository, where we can update the content submodule to point to the latest commit in the `Gibbiverse Content` repository.

When we are in this branch we can then work on the [Hugo](https://gohugo.io/) side of things. We can see what the website looks like locally, by running the [Python](https://www.python.org/) script in the [Gibbiverse Link Fixer](https://github.com/ScottGibb/Gibbiverse-Link-Fixer). This will at present (15-10-2025) replace all the links in the active file location with the correct links for the website. This is important as [Hugo](https://gohugo.io/) will not be able to render the links correctly if they are pointing to my private knowledge base. However this same script is called in the [[GitHub Actions]] workflow when the site is built and deployed.

Once the verification of the website is done and we have made all the tweaks to the [Hugo](https://gohugo.io/) portion of things we then move on Stage 3.

## Stage 3: Releasing your Blog

In Stage 3 we are ready to post our blog to the wider world through [[GitHub Pages]].  We submit a pull request to merge our changes into main. This ensures that our changes are correctly linted through [MegaLinter](https://megalinter.io/latest/) and the code is up to date via [[Dependabot]].

When we are ready to run the release we then simply tag the commit we want to release and send it to [GitHub](https://github.com/ScottGibb). [[GitHub Actions]]  handles the rest and creates a Release on GitHub and then updates the web site accordingly.

# The Quirks and Issues

There are a few quirks and issues that I have found along the way. These are outlined below:

- [Obsidian](https://obsidian.md/) uses Wikilinks primarily and these aren't supported by [Hugo](https://gohugo.io/). This was a relatively easy fix as [Obsidian](https://obsidian.md/) now supports normal Markdown links. So I just need to ensure that I use these in my blog posts.

- Some of my links get replaced with external links. These links are held as key value pairs inside a [[yaml]] file. Within the `Gibbiverse Content` repo.

- Having the blogs reside inside my Vault often means I have a lot of internal links in my posts and these need to be removed before publishing. This is done using the [Python](https://www.python.org/) script in the [Gibbiverse Link Fixer](https://github.com/ScottGibb/Gibbiverse-Link-Fixer) a small [Python](https://www.python.org/) project that can be used to counteract it. It also goes through the code and adds front matter tags. These are also held within the `Gibbiverse Content` repo.

# Closing Remarks

Hopefully this short blog gave an overview of the Blogging workflow and hopefully this workflow continues to work for many future Blogs to come. If you have any questions please reach out on [GitHub](https://github.com/ScottGibb) and post an issue or if you have improvements to the blogs please submit a [[pull request]].

## Repositories

- [Gibbiverse](https://github.com/ScottGibb/Gibbiverse)
- [Gibbiverse Content](https://github.com/ScottGibb/Gibbiverse-Content)
- [Gibbiverse Link Fixer](https://github.com/ScottGibb/Gibbiverse-Link-Fixer)
