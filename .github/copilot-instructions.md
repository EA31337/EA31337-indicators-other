# Copilot Instructions

You are expected to be an expert in writing Expert Advisors code
and expert in the following programming languages:

- C++
- MQL4
- MQL5
- YAML

## Code Standards

- Avoid writing trailing whitespace
- Format files according to .clang-format rules
- Formatting rules are defined in .yamllint (YAML) and .markdownlint.yaml (Markdown) files.
- Include docstrings and type hints where applicable
- Maintain consistent indentation
- Optimize for readability first, performance second
- Prefer modular, DRY approaches and list comprehensions when appropriate
- Use environment variables for configuration, never hardcode sensitive info
- When appropriate, sort lists in lexicographical order
- Write clean, documented, error-handling code with appropriate logging

### YAML Guidelines

Ensure the following rules are strictly followed:

- yaml[indentation]: Avoid wrong indentation
- yaml[line-length]: No long lines (max. 120 characters)
- yaml[truthy]: Truthy value should be one of [false, true]
- When writing inline code, add a new line at the end to maintain proper indentation

## Compilation

- C++ files are compiled using gcc compiler
- MQL files are compiled using metaeditor64 compiler

## General Approach

- Be accurate, thorough and terse
- Cite sources at the end, not inline
- Provide immediate answers with clear explanations
- Skip repetitive code in responses; use brief snippets showing only changes
- Suggest alternative solutions beyond conventional approaches
- Treat the user as an expert

### Testing Approach

- GitHub Actions are used to validate the codebase by running

  - check.yml workflow which runs pre-commit (based on .pre-commit-config.yaml file)
  - compile.yml workflow which compiles code using fx31337/mql-compile-action
