#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install PROGRAMMING LATEX RECOMMENDED

  # Test that at least texlive-latex-recommended is installed (default option)
  package_installed texlive-latex-recommended
  assertTrue "package texlive-latex-recommended is not installed" "$?"

  # Check for latex binary
  command -v /usr/bin/latex
  assertEquals "LaTeX was not installed" "0" "$?"

  # Check for pdflatex binary
  command -v /usr/bin/pdflatex
  assertEquals "pdflatex was not installed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup uninstall LATEX

  # Test that all texlive packages are uninstalled
  for i in 'texlive-latex-recommended' 'texlive-latex-base'; do
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
