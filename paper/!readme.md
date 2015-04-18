#Some notes
This folder contains all the necessary files to export the markdown version of the paper into both `.pdf` and `.docx` files.

Setup of this workflow came from this [blog](http://nikolasander.com/writing-in-markdown/). Sample files can be found there


#Files
#Template
The template is from Keiran Healy's [blog post](http://kieranhealy.org/blog/archives/2014/01/23/plain-text/). It was kind of a pain to install and tweak. If you want to get familiar with what's going on, check it out. Should take about a weekend of tinkering to figure out what's going on if you know a little about `pandoc` and `latex`.

* `template.latex`: Contains formatting information for `.pdf` file
*
##Bibliography files
The bibliography information is contained in the following files

* `chicago.csl`: Contains the bibiliography format
* `sample-library.bib`: Contains the references

##Export files
In order to export the files, use the following tww files

* `exportDOC.sh`: Shell script that executes export process to `.docx`
*  `exportPDF.sh`: Shell script that executes export process to `.pdf`

##Images and figures
Just add the images and figures and reference in the markdown file.

##Example
---  
title: A sample paper  
author: Donald Duck
date: October 1, 2014  
bibliography: sample-library.bib
csl: chicago.csl
reference-docx: path to your style template for MS Word
abstract: Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enimad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
---  

# Section 1  

## Subsection 1.1
Lorem *ipsum* **dolor** sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

## Subsection 1.2
Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque  ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

- one item
- two items
- three items
- four items

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque  ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

You can enter LaTeX equations as inline math: such as $({e}^{i\pi }+1=0)$ or:

$\mathbf{V}_1 \times \mathbf{V}_2 =  \begin{vmatrix}
\mathbf{i} & \mathbf{j} & \mathbf{k} \\
\frac{\partial X}{\partial u} &  \frac{\partial Y}{\partial u} & 0 \\
\frac{\partial X}{\partial v} &  \frac{\partial Y}{\partial v} & 0
\end{vmatrix}$

# Section 2

## Subsection 2.1
Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque  ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque  ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo [link](http://www.http://daringfireball.net). You enter citations using @ and bibtex citation key, such as @donaldduck2014 if you want only the year in brackets, or [@donaldduck2013] for a normal ciation in author-date form within brackets. 

This is the code for an image. Much simpler than in LaTeX. But you can also use LaTeX code here. Just keep in mind that LaTeX code is only rendered when converted to PDF. Conversion to Word or html won't pick it up.

![image caption](sample-image.jpg "beautiful cat")

# References

The reference list is added here automatically by Pandoc: