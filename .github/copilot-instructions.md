# Copilot Instructions for pengwin-setup

## Repository Overview

This repository contains installer scripts for the Pengwin WSL (Windows Subsystem for Linux) distribution. The `pengwin-setup` utility is a configuration and package installation tool that provides a menu-driven interface for users to install various development tools, programming languages, desktop environments, and other software.

## Code Structure and Conventions

### Script Organization

All installer scripts are located in the `pengwin-setup.d/` directory. Each installer component must include:

1. **Main installer script** (`pengwin-setup.d/<name>.sh`)
   - Must source `common.sh` for shared functions
   - Should use `confirm` function to ask user before installation
   - Should use `install_packages` function for package installation
   - Should handle bash-completion files installation when available
   - Should handle fish shell completion files installation when available

2. **Menu entry** in the appropriate menu file:
   - Top-level menus: `tools.sh`, `programming.sh`, `gui.sh`, `editors.sh`, `services.sh`, `settings.sh`, `maintenance.sh`
   - Add entry to the `menu --title` command with proper formatting

3. **Uninstaller script** (`pengwin-setup.d/uninstall/<name>.sh`)
   - Must handle complete removal of installed packages and configurations
   - Located in the `uninstall/` subdirectory

4. **Completion entry** (`completions/pengwin-setup`)
   - Add the new command/option to the bash completion function
   - Follow the existing case statement pattern

5. **Unit test** (`tests/<name>.sh`)
   - Must test both installation and uninstallation
   - Use shunit2 framework (see `tests/commons.sh` for helper functions)
   - Include `test_main()` function for installation testing
   - Include `test_uninstall()` function for uninstallation testing
   - Source `shunit2` at the end of the test file
   - Add test to `tests/run_tests.sh` for CI integration

### Code Style Guidelines

**Follow Google Shell Style Guide** - The project uses the Google Shell Style Guide conventions:

- Use lowercase with underscores for function names: `my_function()`
- Use uppercase for environment variables: `MY_VAR`
- Use local variables with lowercase: `local my_var`
- Include function comments with description, globals, arguments, and returns
- Use shellcheck directives to suppress specific warnings when necessary
- Indent with 2 spaces (no tabs)
- Maximum line length is generally 80 characters but can be flexible for readability

### Shellcheck Compliance

All scripts must pass shellcheck validation:
- Required: No errors (severity=error)
- Recommended: Minimize style warnings
- Exception SC2218 is excluded project-wide
- Use `# shellcheck disable=SCxxxx` for specific necessary exceptions
- Use `# shellcheck source=path/to/file.sh` for sourced files

### Common Patterns

#### Basic Installer Template

```bash
#!/bin/bash

# shellcheck source=common.sh
source "$(dirname "$0")/common.sh" "$@"

if (confirm --title "TOOLNAME" --yesno "Would you like to install Tool Name?" 8 55); then
  echo "Installing Tool Name"
  install_packages package-name
  
  # Install completions if available
  # bash-completion
  # fish completion
else
  echo "Skipping Tool Name"
fi
```

#### Menu Integration Example

In the appropriate menu file (e.g., `tools.sh`):

```bash
menu --title "Tools Menu" "${DIALOG_TYPE}" "Description\n[ENTER to confirm]:" 14 87 5 \
  "NEWTOOL" "Install New Tool description" ${OFF} \
  ...
```

And handle the selection:

```bash
if [[ ${menu_choice} == *"NEWTOOL"* ]]; then
  echo "NEWTOOL"
  bash "${SetupDir}"/newtool.sh "$@"
  exit_status=$?
fi
```

#### Test Template

```bash
#!/bin/bash

source commons.sh

function test_main() {
  run_pengwinsetup install CATEGORY TOOLNAME

  for i in 'package-name' ; do
    package_installed $i
    assertTrue "package $i is not installed" "$?"
  done

  command -v /usr/bin/tool-binary
  assertEquals "Tool was not installed" "0" "$?"
}

function test_uninstall() {
  run_pengwinsetup install UNINSTALL TOOLNAME

  for i in 'package-name' ; do
    package_installed $i
    assertFalse "package $i is not uninstalled" "$?"
  done

  command -v /usr/bin/tool-binary
  assertEquals "Tool was not uninstalled" "1" "$?"
}

# shellcheck disable=SC1091
source shunit2
```

### Command-Line Interface

The `pengwin-setup` tool supports both interactive and non-interactive modes:

- Interactive: `pengwin-setup` (shows menu)
- Non-interactive: `pengwin-setup install CATEGORY ITEM`
- Automated: `pengwin-setup --yes --noninteractive install CATEGORY ITEM`

Ensure new components work in both modes.

### Testing

Before submitting changes:

1. Run shellcheck on modified scripts:
   ```bash
   shellcheck -e SC2218 --external-sources --severity=error pengwin-setup.d/yourscript.sh
   ```

2. Run unit tests locally if possible (requires Debian/Pengwin environment):
   ```bash
   cd tests
   ./run_tests.sh
   ```

3. Verify bash completion works:
   ```bash
   source completions/pengwin-setup
   ```

### Files to Update When Adding New Installer

When adding a new installer component, update these files:

1. `pengwin-setup.d/<name>.sh` - Main installer script
2. `pengwin-setup.d/<category>.sh` - Add menu entry (tools.sh, programming.sh, etc.)
3. `pengwin-setup.d/uninstall/<name>.sh` - Uninstaller script  
4. `pengwin-setup.d/uninstall.sh` - Add to uninstall menu
5. `completions/pengwin-setup` - Add bash completion
6. `tests/<name>.sh` - Unit test
7. `tests/run_tests.sh` - Add test to run script

### Important Notes

- Scripts must be executable: `chmod +x script.sh`
- Always test in WSL environment when possible
- Use `createtmp` function from common.sh for temporary files
- Clean up temporary files and resources
- Handle errors gracefully with meaningful messages
- Consider both WSL1 and WSL2 environments when relevant
- Be mindful of Windows/Linux path interactions in WSL
- **Prefer `dialog` over `whiptail`** - whiptail is legacy and the project is migrating to dialog

## Common Functions (from common.sh)

Key functions available in all scripts:

- `confirm` - Show confirmation dialog
- `menu` - Show menu selection dialog
- `install_packages` - Install apt packages with proper error handling
- `upgrade_packages` - Upgrade packages
- `createtmp` - Create temporary directory
- `dialog` - Dialog command for UI (preferred over legacy `whiptail`)
- Various progress indicators and utility functions

## Getting Help

- Look at existing scripts in `pengwin-setup.d/` for examples
- Check test examples in `tests/` directory
- Review `common.sh` for available shared functions
- Follow the established patterns in the codebase
