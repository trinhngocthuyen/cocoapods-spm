# Contributing

You are more than welcome to contribute to the project in various ways:
- Implement features
- Fix bugs
- Write tests
- Write documentation

The following section describes the development workflow when contributing to the project.

## Development Workflow

**Step 1. Clone the project**

```sh
git clone https://github.com/trinhngocthuyen/cocoapods-spm.git && cd cocoapods-spm/
```

**Step 2. Install dependencies**

```sh
make install
```

**Step 3. Make changes**

You can try out your changes with the example project at `examples`:
- Run `make ex.install` to trigger pod install for the example project
- Build (or test) the project with Xcode

**Step 4. Format changes**

This project is using `pre-commit` (which is installed in step 2) to lint & format changes.\
By default, pre-commit auto lints and formats your changes. Therefore, make sure step 2 succeeded.\
In case you want to trigger the format, simply run `make format`.

**Step 5. Run tests**

- Unit test: `make test.unit`
- Integration test: `make test.integration`

**Step 6: Commit changes and create pull requests**
