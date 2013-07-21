# Other Package Manager

## DESCRIPTION

OPM is intended to be a light weight package manager for Linux. Designed to be a simple framework wrapping around downloading, unpacking, configuring, compiling and installing packages built from source code.

It is not my intention for this to be some attempt at a _be all and end all_ of package management. This is a personal project, something I have wanted to dabble with for a long time. Nothing more than a learning exercise that I myself may find useful.

If you find it interesting and or useful, awesome. But I wouldn't go looking for too much support.

## INSTALLATION

```
git clone git@github.com:trq/opm.git
./install.sh
cd var
git clone git@github.com:trq/opms.git
```

Put opm/bin on your PATH.

OPM is currently being developed alongside the building of an [LFS](http://linuxfromscratch.org) system. The intention is to have a set of build scripts for at least chapters 5 & 6. Within these build scripts will be a build script for OPM to install OPM.

If you intend on using OPM to build and or maintain your LFS system, it would be awesome if you got in touch.

## DOCUMENTATION

This is it. Live with it.

### Usage

```
opm list
  list installed builds

opm sync
  sync the package repository with upstream

opm help
  show this help screen

opm category/package-version <action>

Available actions:

  Utils:
    unmerge     : remove the package from the root filesystem
    clean       : clean the build directory
    purge       : remove the sandbox
    info        : display information about an installed package

  Stages:
    fetch       : download source archive(s) and patches
    unpack      : unpack sources
    prepare     : prepare source
    configure   : configure sources
    compile     : compile sources
    preinstall  : pre install utility
    install     : install the package to the temporary install directory
    postinstall : post install utility
    package     : package the package into a tarball
    merge       : merge the packaged tarball into the root filesystem
```

### Stages

Most of the design ideas for OPM stem from [Gentoo](http://gentoo.org)'s Portage. More specifically at this stage, the ebuild system.

The Util actions described above are what they are, the Stage actions however, have dependencies between each other.

To install a package into your system you could issue:

```
opm sys-apps/sed-3.0 fetch unpack prepare configure compile preinstall install postinstall package merge
```

Having to type all of that each time you want to install a package would however quickly become a PITA. Instead, if you know the outcome you want to achieve is to do a merge, just tell OPM to do that:

```
opm sys-apps/sed-3.0 merge
```

OPM is smart enough to know that merge depends on package, and package depends on postinstall, and postinstall depends on install etc etc.

The longer form is really only useful when you are developing a build script and need to step through each stage slowly and inspect things as they are processed.

```
opm sys-apps/sed-3.0 fetch
opm sys-apps/sed-3.0 unpack
# do some work scripting the prepare stage
opm sys-apps/sed-3.0 prepare
```

### How are stage dependencies handled?

Each stage is responsible for registering itself with the stage manager, letting the stage manager know what stage the current stage depends on, doing its work and then finally letting the stage manager know that it has completed.

```
opm.postinstall() {
    opm.stage.start "postinstall"
    opm.stage.requires "install"

    # Stage does its work here

    opm.stage.complete "postinstall"
}
```

With this basic skeleton in place, calling "postinstall" without firstly calling "install" will automatically have "install" called. This design has a chain effect. Given the "merge" action, the process works like this:

1. The _merge_ stage starts.
2. Merge's dependency _package_ is checked to see if it has started, it starts
3. Package's dependency _postinstall_ is checked to see if it has started, it starts

This process continues all the way down to the _fetch_ stage which no dependencies. It starts, does it's work, then registers itself as complete. This triggers the process again in reverse.

1. The _unpack_ stage does it work, then registers itself as complete
2. The _prepare_ stage does its work then registers itself as complete
3. The _configure_ stage does its work then registers itself as complete

This process goes all the way back up the chain until finally _merge_ (the stage we requested) does its work, and registers itself as complete.

## CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
