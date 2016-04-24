VERSION=0.1.0
.PHONY: test

push:
	echo 'make gempush/gitpush'

# rake build          # Build re_expand-0.1.0.gem into the pkg directory
# rake install        # Build and install re_expand-0.1.0.gem into system gems
# rake install:local  # Build and install re_expand-0.1.0.gem into system gems
#                     # without network access
# rake release        # Create tag v0.1.0 and build and push re_expand-0.1.0.gem to Rubygems
# rake test           # Run tests

gitpush:
	git push git@github.com:masui/expand_ruby.git

test:
	rake test
