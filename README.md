# `flake`

> Identify problematic jest tests

This is a Bash CLI script for identifying "flaky" jest tests

## Usage

```bash
./flake.sh [-s jest_script] [-i iterations] [-j] [-h]
```

**note** In a CI environment, it is convenient to run `flake_ci.sh` as this file has no dependencies

## Options

- `-s jest_script`: Specify the jest test script (default: npm run test -- --json)
- `-i iterations`: Specify the number of test iterations (default: 100)
- `-d directory`: Specify the directory to run the test script (default: current directory)
- `-j`: Save jest --json outputs (default: false)
- `h`: Display a help message

## Analyze `--json` output files

If this script hangs or fails, it can be useful to run an analysis on the persisted `--json` output files generated from this CLI

```bash
./flake_on_files.sh [-d directory] [-h]
```

### Options

- `-d directory`: Specify the directory where the jest JSON files reside (default: current directory)
- `h`: Display a help message

## Github Action

```yaml
name: Flake

on:
  schedule:
    - cron: "0 0 * * 0"

jobs:
  run-flake:
    runs-on: ubuntu-latest
    timeout-minutes: 60

    steps:
      - name: Clone project
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install npm
        run: npm install -g npm

      - name: Install dependencies
        run: npm install

      - name: Checkout flake repo
        uses: actions/checkout@v3
        with:
          repository: neo-andrew-moss/flake
          ref: main
          path: flake

      - name: Run flake
        run: |
          chmod +x ./flake/flake_ci.sh
          ./flake/flake_ci.sh -s 'npm run test -- --silent --json --maxWorkers=4' -i 100 > flake_logs.txt

      - name: Print results
        run: |
          echo "Flake results:"
          cat flake_logs.txt
```

**note** This uses a lot of CI minutes. Be careful.
