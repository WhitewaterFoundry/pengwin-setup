#!/bin/bash
source commons.sh

function test_install_with_intelliJ_installed_but_without_wsldistributions_file() {

  APPDATA_PATH="$(wslpath -u "$(wslvar APPDATA)")"
  IDEA_PATH="$APPDATA_PATH/JetBrains/Idea"
  OPTIONS_FOLDER="$IDEA_PATH/options"
  run_command_as_testuser "mkdir -p $OPTIONS_FOLDER"

  run_pengwinsetup autoinstall PROGRAMMING JETBRAINS

  test -f "${OPTIONS_FOLDER}/wsl.distributions.xml"
  assertTrue "The file wsl.distributions.xml was no created" "$?"
  run_command_as_testuser "rm -R $APPDATA_PATH"

}

function test_install_with_intelliJ_installed_and_there_is_file_with_similar_name_to_wsldistributions_file() {

  APPDATA_PATH="$(wslvar APPDATA)"
  JETBRAINS_PATH="$APPDATA_PATH/JetBrains"

  copy_distribution_file "$JETBRAINS_PATH/Idea2020" "other.wsl.distributions.xml"

  run_pengwinsetup autoinstall PROGRAMMING JETBRAINS

  test -f "${OPTIONS_FOLDER}/wsl.distributions.xml"
  assertTrue "The file wsl.distributions.xml was no created" "$?"
  run_command_as_testuser "rm -R $APPDATA_PATH"

}

function test_install_with_multiple_intelliJ_tools_installed() {
  APPDATA_PATH="$(wslvar APPDATA)"
  JETBRAINS_PATH="$APPDATA_PATH/JetBrains"

  copy_distribution_file "$JETBRAINS_PATH/Idea2020" "wsl.distributions.xml"
  copy_distribution_file "$JETBRAINS_PATH/Idea2021" "wsl.distributions.xml"
  copy_distribution_file "$JETBRAINS_PATH/rubyMine2020" "wsl.distributions.xml"

  run_pengwinsetup autoinstall PROGRAMMING JETBRAINS

  assertTrue "The file wsl.distributions.xml Should no have any distribution with Pengwin as microsoft-id" "[ -z $(grep -Rl "<microsoft-id>Pengwin</microsoft-id>" "$JETBRAINS_PATH" | grep "wsl.distributions.xml") ]"
  run_command_as_testuser "rm -R $APPDATA_PATH"
}

function copy_distribution_file() {

  OPTIONS_FOLDER="$1/options"
  CURRENT_FOLDER="$(pwd)"
  run_command_as_testuser "mkdir -p $OPTIONS_FOLDER"
  run_command_as_testuser "cp $CURRENT_FOLDER/template-wrong-value-wsl.distributions.xml $OPTIONS_FOLDER/$2"
}

source shunit2
