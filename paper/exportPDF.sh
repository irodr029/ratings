#This changes the current directory to where the markdown file is
cd "/Users/ivan/Desktop/Ratings/paper"

#Using pandoc, we convert sample.md
#to sample-paper.pdf
#using the template: template.latex
pandoc -S -o sample-paper.pdf --latex-engine=xelatex --template=template --filter pandoc-citeproc sample.md