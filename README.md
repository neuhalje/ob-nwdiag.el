ob-nwdiag.el
---------------

An extension for org-babel to support [nwdiag](http://blockdiag.com/en/).

## Installation

Please install from the repo.

Now you could enable this package in your Emacs config with:

``` emacs-lisp
(org-babel-do-load-languages 'org-babel-load-languages
 '((nwdiag . t))
)
```

## Example


``` org
#+BEGIN_SRC nwdiag :tool nwdiag-3.5 :file ololo.png
nwdiag {
  network dmz {
      address = "210.x.x.x/24"

      web01 [address = "210.x.x.1"];
      web02 [address = "210.x.x.2"];
  }
  network internal {
      address = "172.x.x.x/24";

      web01 [address = "172.x.x.1"];
      web02 [address = "172.x.x.2"];
      db01;
      db02;
  }
}
#+END_SRC
```

## Arguments

There are some things you could customize:

    - `:tool` if you have nwdiag in unusual location or want to use seqdiag or [others](http://blockdiag.com/en/#table-of-contents)
    - `:transparency t` to make transparent background of diagram (PNG only)
    - `:antialias t` pass diagram image to anti-alias filter
    - `:font` if you want the `:tool` to use provided font
    - `:size` if you want the `:tool` to use custom size
    - `:type` if you want the `:tool` to use different file format type, e.g. pdf, svg

## Errors and output

It recreates a buffer with name `*ob-nwdiag*` every time you evaluating something.

There will be errors and output.
