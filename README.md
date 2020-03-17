# Autobrew Core

System libraries for building R packages.

## What is this

CRAN currently targets MacOS 10.11 (El-Capitain), however this version of MacOS is no longer supported by Apple, and the latest Homebrew no longer works there. Autobrew is a fork from upstream [homebrew-core](https://github.com/homebrew/homebrew-core) from the last day of MacOS 10.11 support. We selectively backport and adapt system libraries needed for building R packages.

This is not an officially supported project. All of this is a bit hacky and may not work for all libraries.

## Contributing

If you send a pull request, the formula that has been changed will automatically be built on Travis CI. In addition some tests and reverse dependencies are checked. 

At the end of the CI run the new binary bottle is uploaded to `file.io` and you see a download link in the Travis log.
 