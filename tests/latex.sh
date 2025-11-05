#!/bin/bash

source commons.sh

function testMain() {
  run_pengwinsetup install PROGRAMMING LATEX FULL

  # Test that at least texlive-full is installed (default option)
  package_installed texlive-full
  assertTrue "package texlive-full is not installed" "$?"

  # Check for latex binary
  command -v /usr/bin/latex
  assertEquals "LaTeX was not installed" "0" "$?"

  # Check for pdflatex binary
  command -v /usr/bin/pdflatex
  assertEquals "pdflatex was not installed" "0" "$?"
}

function testUninstall() {
  run_pengwinsetup uninstall LATEX

  # Test that all texlive packages are uninstalled
  for i in 'texlive-full' 'texlive-latex-extra' 'texlive-latex-recommended' 'texlive-latex-base'; do
    package_installed "$i"
    assertFalse "package $i is not uninstalled" "$?"
  done

  # Check latex binary is removed
  command -v /usr/bin/latex
  assertEquals "LaTeX was not uninstalled" "1" "$?"

  # Check pdflatex binary is removed
  command -v /usr/bin/pdflatex
  assertEquals "pdflatex was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
