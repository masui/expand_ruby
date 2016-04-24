VERSION=0.1.2
.PHONY: test

test:
	rake test

# Build re_expand gem into the pkg directory
build:
	rake build

# Build and install re_expand gem into system gems
install:
	rake install

# Create tag v?.?.? and build and push re_expand gem to Rubygems
release:
	rake release

# Push to GitHub
push:
	git push git@github.com:masui/expand_ruby.git

