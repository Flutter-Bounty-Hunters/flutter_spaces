# Flutter Spaces

Welcome to the repository for the marketing website for the weekly Flutter Spaces call!

This website is intended to help people share info about upcoming calls and hosts.

## Build and run locally
This website is built with [Static Shock](https://staticshock.io).

Sources files can be found in `source/`.

Build files for deployment can be found in `build/`.

To build locally, first install `static_shock_cli` as a global Dart dependency:

```bash
dart pub global activate static_shock_cli
```

After installing `static_shock_cli`, navigate to this project directory and run a build:

```bash
shock build
```

If you'd like to test the website locally, use the built-in development server:

```bash
shock serve
```

## Deploy the website
The website is built and deployed with a GitHub action. To see how that works, see `.github/workflows/deploy.yaml`.