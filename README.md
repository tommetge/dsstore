# DS_Store Utils

This is a utility for examining (and, in the future, modifying) .DS_Store files.

You've probably noticed those pesky little files floating around your hard drive. If you don't already know what they do, take a look at [Wikipedia's article](http://en.wikipedia.org/wiki/.DS_Store). Love them or hate them, Finder makes sure they're here to stay.

The utility this repository provides (dsstore) can read these files and let you know what they contain. This can be useful if you're debugging Finder and associated behavior.

## Installation

Clone the repo, build, and the build output will be a single executable called, "dsstore".

## Usage

    dsstore [path/to/.DS_Store]

Example:

    dsstore ~/Public/.DS_Store

Example output:

    2013-06-14 11:15:23.855 dsstore[1606:707] Section: 0 (6 chunks)
    2013-06-14 11:15:23.858 dsstore[1606:707] "Drop Box" = {
      bwsp = {
        ShowPathbar = 0;
        ShowSidebar = 1;
        ShowStatusBar = 1;
        ShowToolbar = 1;
        SidebarWidth = 192;
        WindowBounds = "{{456, 373}, {806, 486}}";
    }
    }
    2013-06-14 11:15:23.859 dsstore[1606:707] "Drop Box" = {
      lg1S = 33039992
    }
    2013-06-14 11:15:23.859 dsstore[1606:707] "Drop Box" = {
      moDD = 226186142023680
    }
    2013-06-14 11:15:23.860 dsstore[1606:707] "Drop Box" = {
      modD = 226186142023680
    }
    2013-06-14 11:15:23.860 dsstore[1606:707] "Drop Box" = {
      ph1S = 33042432
    }
    2013-06-14 11:15:23.861 dsstore[1606:707] "Drop Box" = {
      vSrn = 1
    }
    2013-06-14 11:15:23.861 dsstore[1606:707] Section: 1 (0 chunks)

## Credits

This would have been utterly impossible without the ground work laid by [Wim Lewis](http://search.cpan.org/~wiml/Mac-Finder-DSStore-0.96/DSStoreFormat.pod) and [Mark Mentovai](https://wiki.mozilla.org/DS_Store_File_Format). An excellent parsing example is also available in the [Xee repository](https://github.com/albertz/Xee/blob/master/CSDesktopServices.m).

Thanks!

## License

MIT license. Feel free to use and abuse.
