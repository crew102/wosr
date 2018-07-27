all: doc README.md site

# Removed dep on README.Rmd b/c want to re-render each time (don't care about
# changes in README.Rmd)
README.md:
	- Rscript -e "rmarkdown::render('README.Rmd', output_file = 'README.md', output_dir = getwd(), output_format = 'github_document', quiet = TRUE)"
	- rm README.html

# Document package
doc:
	Rscript -e "devtools::document()"

# Test package
test:
	Rscript -e "devtools::test()"

# Build site
site:
	Rscript -e "source('inst/site/build-site.R'); build_site()"

# Clean
clean:
	rm -R README.md docs

.PHONY: doc README.md site test clean
