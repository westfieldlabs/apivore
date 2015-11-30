# Contributing

Contributions can be made to this gem by following the steps below: 

First raise an issue outlining the contribution you believe needs to be included.

Then fork the repository into your own GitHub account and clone it to your development environment.

    git clone git@github.com:your-username/apivore.git
    
Make sure the tests pass:

    rspec

Create a working branch off master that references the issue number of the issue you created.

    git checkout -b 123_what_am_I_doing
    git push -u origin 123_what_am_I_doing

Add tests for your change, make your change. Make sure all the tests pass:

    rspec

When you are satisfied that the change you wanted to make is done, then submit a pull request for review.

We aim to respond to pull requests within a few business days, and, typically, within one business day. Our core team is dispersed between San Francisco and Sydney.

If we suggest some changes, improvements, or alternatives then please act on them. Please ensure you conform to the coding style in place. 2 spaces instead of tabs, that sort of thing.

## Pull requests will be rejected if they:

* Don't come with adequate tests
* Don't follow our coding style
* Don't reference a GitHub issue
* Are not accompanied by good commit messages

Thank you for helping make Apivore better!
