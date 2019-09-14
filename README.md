# AutoDiff Example for PHY 604

This is a simple example of forward autodiff for PHY 604 (Graduate Computing
II).  We live-coded most of the scaffolding in class today; but after class I
cleaned up the type promotion and added a bunch of examples and tests.  The
`ForwardAutodiff.ipynb` notebook has some comments and tries to explain what the
code is doing.

For proper use we will want a library that we can import and use, so I extracted
the code and put it into a module (and the tests in an automated test suite,
too).  If you would like to try it in your code, fire up Julia, enter the
package mode (press `]`), and enter the command

    add https://github.com/Farr-PHY-604/ForwardAutodiff.jl.git

that will download this package and add it to the package manifest for the
currently-active environment.  Then you can do cool stuff like

    using ForwardAutodiff

    cos_from_derivative = D(sin)

    print(cos_from_derivative(1.234) - cos(1.234))  # Should be close to zero

    cycloid_tangent_vector = D(t -> [cos(2*pi*t), sin(2*pi*t) t])
    print(cycloid_tangent_vector(2)) # It points somewhere...

Forward-mode autodiff is efficient for functions from R to R or R to R^N; if you
have a function from R^N to R, check out the partner
[BackwardAutodiff](https://github.com/Farr-PHY-604/BackwardAutodiff.jl) module,
which can efficiently compute gradients of R^N to R functions.  

TODO: permit differentiation wrt more than one variable at a time (i.e.
D(D(sin)) = sin).  Expand derivatives to more functions.  Maybe implement
backward Autodiff?  More stress testing!

Note: if you just want to run the tests for this package, then clone the git
repo, enter the top-level directory, fire up Julia, enter package mode (type
`]`), and then

    test

Julia knows to run the `test/runtests.jl` program in the correct environment.
Everything should pass, of course!
