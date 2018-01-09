all: doc test

# Document package (object docs)
doc:
	Rscript -e "devtools::document()"

# Test package
test:
	Rscript -e "devtools::test()"
