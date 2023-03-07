# `flake`

> Identify problematic jest tests

This is a Bash CLI script fir identifying "flaky" jest tests

## Usage

```bash
./flake.sh [-s jest_script] [-i iterations] [-j] [-h]
```

## Options

- `-s jest_script`: Specify the jest test script (default: npm run test -- --json)
- `-i iterations`: Specify the number of test iterations (default: 100)
- `-j`: Save jest --json outputs (default: false)
- `h`: Display a help message

## Analyze --json output files

If this script hangs or fails, it can be useful to run an analysis on the persisted `--json` output files generated from this CLI

```bash
output_file="failing_tests.txt"

>"$output_file"

for file in *.json; d
  jq -r '.testResults[].assertionResults[] | select(.status == "failed") | .fullName' "$file" >>"$output_file"
done
```
