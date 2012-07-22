fyzicks
=======

Playing around with chipmunk physics and chingu!

Required Gems
------------
Bundler, Chipmunk, Chingu

Install
-------

* clone
* bundle
* run

Bugs
----

OSX llvm might give you trouble, like shrinking/exploding polygons as they rotate. Use the osx gcc installer, export these, delete the gemset then bundle.

    export CC=gcc-4.2
    export CXX=g++-4.2

Notes
-----

Change the .rvmrc if you'd like to use ruby 1.9.2
Probably works with 1.8.7 if you go back to old hash style.

    Ship sprites come from http://gushh.net/blog/spaceship-generator/
