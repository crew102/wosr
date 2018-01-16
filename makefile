all: doc README.md vig

# Render README.Rmd to README.md
README.md: README.Rmd
	Rscript -e "rmarkdown::render('README.Rmd', output_file = 'README.md', output_dir = getwd(), output_format = 'github_document', quiet = TRUE)"
	Rscript -e "file.remove('README.html')"

# Document package
doc:
	Rscript -e "devtools::document()"

# Compile vignettes
vig: vignettes/*
	Rscript -e "devtools::build_vignettes()"

# Test package
test:
	Rscript -e "devtools::test()"

# Build site (not part of all)
site: _pkgdown.yml
	Rscript -e "pkgdown::build_site()"

# Clean
clean:
	rm -R README.md inst/doc docs
