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

Ubuntu 12.04 had an error about libiconv_open missing from gosu.so. If you go into the gem folder, edit the Makefile to include -liconv it works.

Notes
-----

Change the .rvmrc if you'd like to use ruby 1.9.2
Probably works with 1.8.7 if you go back to old hash style.

    Ship sprites come from http://gushh.net/blog/spaceship-generator/
