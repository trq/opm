# Other Package Manager

## DESCRIPTION

OPM is intended to be a light weight package manager for Linux. Designed to be a simple framework wrapping around downloading, unpacking, configuring, compiling and installing packages built from source code.

It is not my intention for this to be some attempt at a _be all and end all_ of package management. This is a personal project, something I have wanted to dabble with for a long time. Nothing more than a learning exercise that I myself may find useful.

If you find it interesting and or useful, awesome. But I wouldn't go looking for to much support.

## INSTALLATION

OPM is currently being developed alongside the building of an [LFS](http://linuxfromscratch.org) system. The intention is to have a set of build scripts for at least chapters 5 & 6. Within these build scripts will be a build script for OPM to install OPM.

For the moment, clone the repo, create the required directories then clone the opms.

```
git clone https://github.com/trq/opm.git
cd opm
mkdir -p var/opm tmp/opm
git clone https://github.com/trq/opms.git var/opm/opms
```

If you intend on using OPM to build and or maintain your LFS system, it would be awesome if you got in touch.

## DOCUMENTATION

This is it. Live with it.

### Usage

What can this thing do?

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

### An Overview

This section aims to provide a high level overview of OPMs design, how it build packages and how you can create your own build scripts to work with OPM.

A lot of the ideas that have gone into OPM stem from my use of [Gentoo](http://gentoo.org)'s portage. More specifically, its ebuild system. In fact the basic premise is the same.

1) Download the source code for a package
2) Unpack the source in a temporary location
3) Apply any required patches
4) Configure the source
5) Compile the source
6) Install into a temporary location
7) Copy the finished product into the live file system

This process is achieved by abstracting away as much of this functionality as possible into reusable components called _stages_. Each stage in the process has a default function that is generic / flexible enough to use in most situations, and for the situations it's not prepared for, it is overwritten by a more specific function.

When a stage is invoked a number of events take place.

```
opm sys-apps/sed-3.0 merge
```

Firstly, within bin/opm a number of globally available variables are set, the OPM libraries are sourced and control is then handed over (for the moment) to the _bootstrap_ script.
Bootstrap is responsible for setting up package specific variables (by inspecting the requested packages category, name and version), sourcing all configuration files, and setting up environment variables required by the sandbox.
Once bootstrap is complete, execution is handed back over to bin/opm where the opm.main function is called. This function is responsible for sourcing the base build script, the specific package/version build script and then executing the requested stages.

### Build Scripts

Build scripts are where we can customise the build process for a particular package. Within them you can set variables specific to your package, as well as overwrite the built in _stage_ functions.

Build scripts are located in the opms repository within a there respective categories directory. Each package can define a base.opm (which is used to store common functionality / variables between versions) and then any number of version specific build scripts.

```
.
├── lfs-base
│   ├── gcc
        ├── base.opm
        ├── 4.7.2.opm
```

Within a build script, there are a few important variables that need to be set. An example here shows the base.opm for the lfs/gcc package:

```
sources=( "http://ftp.gnu.org/gnu/${PACKAGE_NAME}/${PACKAGE_NAME}-${PACKAGE_VERSION}/${PACKAGE_NAME}-${PACKAGE_VERSION}.tar.bz2" )
description="The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
```

Don't worry about the upper cased variables for the moment, these will be explained later, for now, just take note of the variables that are being declared here. Because these variables wont change between versions, these can be abstracted away into a <category>/<package>/base.opm build script. The base.opm files are sourced prior to any more specific <category>/<package>/<version>.opm files.

Currently, the variables that can be set within a built script are:

An array of urls where the source code for this package can be downloaded
```
sources
```

The description of the package
```
description
```

The md5 checksum of the package. If set, this will be checked during the _unpack_ stage.
```
checksum
```

Renames the downloaded archive to whatever is defined within
```
archive
```

As OPM is bootstrapped, various functions are made available within the current environment by sourcing the libraries they are defined in. The _stage_ functions in particular are brought into being through this process. These are the functions that abstract away most of the common functionality required to build a package. It is these _stage_ functions that our build scripts can override to provide more specific functionality to the OPM build process.

For example, the default configure stage looks like this. This provides a sane default that will work for a lot of packages.

```
opm.configure() {
    opm.stage.start "configure"
    opm.stage.requires "prepare"
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    opm.util.configure \
        --prefix=${CONFIG_PREFIX:=/usr} \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --datadir=/usr/share \
        --sysconfdir=/etc \
        --localstatedir=/var/lib \
        --disable-dependency-tracking

    opm.stage.complete "configure"
}
```

However, at times we will need to customise the way packages are configured. We can do this by simply overwriting the opm.configure function within our build script.

```
opm.configure() {
    opm.stage.start "configure"
    opm.stage.requires "prepare"
    opm.util.requires_dir ${BUILDDIR}

    msg "Configuring source ..."
    cd "$BUILDDIR";

    opm.util.configure \
        --prefix=${CONFIG_PREFIX}   \
        --with-sysroot=$LFS         \
        --with-lib-path=${CONFIG_PREFIX}/lib  \
        --target=${CONFIG_TARGET}   \
        --disable-nls               \
        --disable-werror

    opm.stage.complete "configure"
}
```

### Stage Dependencies Explained.

_Stage_ actions execute the functions that perform the bulk of the work needed to be carried out to install a package. It is imperative that these stages be executed in a specific order.

To install gcc into your system for instance, you would execute all the stages, one after the other.

```
opm lfs-base/gcc-4.7.2 \
    fetch unpack prepare configure \
    compile preinstall install postinstall \
    package merge
```

Having to type all of that each time you want to install a package would however quickly become a PITA. Instead, if you know the outcome you want to achieve is to do a merge, just tell OPM to do that:

```
opm sys-apps/sed-3.0 merge
```

OPM is smart enough to know that merge depends on _package_, and _package_ depends on _postinstall_, and _postinstall_ depends on install etc.

The explicit form is really only useful when you are developing a build script and need to step through each stage slowly and inspect things as they are processed.

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

With this basic skeleton in place, calling _postinstall_ without firstly calling _install_ will automatically have _install_ called. This design has a chain effect. Given the _merge_ action, the process works like this:

1. The _merge_ stage starts.
2. Merge's dependency _package_ is checked to see if it has started, it starts
3. Package's dependency _postinstall_ is checked to see if it has started, it starts

This process continues all the way down to the _fetch_ stage which no dependencies. It starts, does it's work, then registers itself as complete. This triggers the process again in reverse.

1. The _unpack_ stage does it work, then registers itself as complete
2. The _prepare_ stage does its work then registers itself as complete
3. The _configure_ stage does its work then registers itself as complete

This process goes all the way back up the chain until finally _merge_ (the stage we requested) does its work, and registers itself as complete.

If, while a stage is doing its work an error occures, you can (and likely should) register the stage as failed.

```
opm.stage.fail
```

This will prevent any dependent stages from executing which would potentially cause more issues.

The only caveat to this entire mechanism is the fact that there is an amount of boiler plate required to override a stage with your own custom implementation. If you don't however supply this boiler plate, your will inevatably break the dependency chain, and your users ability to install packages cleanly and easily.

### The sandbox

As a package is being built, we need an area to work in. This is what the sandbox is.

```
.
└── gcc-4.7.2
    ├── build
    ├── inst
    ├── stage
    └── work
        └── gcc-4.7.2
```

This example shows the higher levels of the sandbox created to build gcc-4.7.2.

* The build directory is where packages are built
* The inst directory is where they will be installed into
* The stage directory is where the stage manager stores its meta data
* The work directory is where the archive is unpacked. This typically creates another directory named after the package. It is this directory that the `$SOURCEDIR` variable refers to (see below).

### Globally available variables

Within the build script environment there are a few variables available to you to make locating things easier. They are:

The path to the opm script
```
OPM
```

The path to the root of opm
```
OPMDIR
```

The location of the build scripts repository
```
OPMS
```

The target file system
```
TARGETFS
```

The location downloaded archives are stored in
```
DISTDIR
```

The location compiled packages are stored in
```
PKGDIR
```

The location of all package meta data
```
METADIR
```

The category of the current package
```
CATEGORY
```

The name of the current package
```
PACKAGE_NAME
```

The version of the current package
```
PACKAGE_VERSION
```

The revision of the current package (if any)
```
PACKAGE_REVISION
```

The <name>-<version>_<revision> of the current package
```
PACKAGE
```

The location of the sandbox for the current package
```
SANDBOX
```

The location of the stage directory. This directory is used to store meta data required by the stage manager to track stage status.
```
STAGEDIR
```

The location the package will be installed into. This is only the temporary install location.
```
INSTDIR
```

The location the archive will be unpacked into
```
WORKDIR
```

The location the package will be built in
```
BUILDDIR
```

The location of the package source
```
SOURCEDIR
```

## CONTRIBUTING

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
