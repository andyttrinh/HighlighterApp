# Repository Guidelines

## Build, Test, and Development Commands

No build or test commands are configured yet. When adding tooling, list the exact commands here. For example:
- `npm run dev` for local development
- `npm test` for running tests
- `make build` for production builds

Keep these commands up to date so contributors can run the project without guesswork.

## Coding Style & Naming Conventions

No code style has been defined yet. When introducing a language or framework:
- Set indentation and formatting rules (for example, 2 or 4 spaces).
- Add a formatter or linter and document how to run it.
- Choose consistent naming patterns (for example, `PascalCase` for types, `camelCase` for variables).

Record the chosen conventions here to avoid drift.

## Testing Guidelines

No test framework is currently configured. If you add tests:
- Specify the test runner and where tests live.
- Define naming conventions (for example, `*.test.ts` or `*_spec.rb`).
- Note coverage expectations, if any, and how to run test suites.

## Commit & Pull Request Guidelines

There is no commit history yet. Adopt a simple convention and document it here, such as:
- `feat: add highlight rendering`
- `fix: handle empty input`

For pull requests, include:
- A short description of the change
- Linked issues or context
- Screenshots or logs when behavior changes

## Security & Configuration Tips

If you add secrets or environment-specific settings, store them in a `.env` file and add `.env` to `.gitignore`. Provide a `.env.example` with safe defaults.

## Instruction for Working
- For every question and feature update make sure you refer to the code base in HighlightApp directory. You should have complete knowledge of the codebase as it's changing when answering my question since this is what we will be working on. Please take the time to review everything in the HighlightApp Directory and understand the goal and how the app works.

## Initial Description
This project is an IOS Highlighter App. The functionality of this app is to be a app that allows users to highlight lines and store them as highlights in the app. The user should be able to highlight a line from any app then click the "share" option and share the text to the highlighter app. This functionality is similar to how Instapaper works where you can share links to the app. There will be added functionality like having tags to highlights and sorting highlights, but for now we want a prototype. 

## Notes To Be Followed While Developing
- Periodically perform git commits with informative comments while developing.
- Please create new branches for developming new features and then after done merge them back to the main branch.