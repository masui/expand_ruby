VERSION=0.1.1
.PHONY: test

test:
	rake test

# Build re_expand-0.1.0.gem into the pkg directory
build:
	rake build

# Build and install re_expand-0.1.0.gem into system gems
install:
	rake install

# Create tag v0.1.0 and build and push re_expand-0.1.0.gem to Rubygems
release:
	rake release

# Push to GitHub
push:
	git push git@github.com:masui/expand_ruby.git

