# crosstabcsv
Emulates PSQL's `\crosstabview` for CSV files. Useful in conjunction with `psql -c` commands.

## Why?

`\crosstabview` is a meta-command that is processed by the `psql` CLI itself, rather than being sent as an SQL command to the database server. That is to say: it is only changing the shape of the output, as opposed to affecting what data is requested. Because it's only available within the interactive shell, if we want to get a cross-tabbed view of a query fetched remotely (`psql -c`), we can do `psql -c --csv "<query>" | crosstabcsv`.

## Installation

This is a bash function, so you just need to `source` the .sh file in your .bashrc/zshrc. e.g.:

```bash
. /path/to/crosstabcsv/crosstabcsv.sh
```

Alternatively, paste the function directly into that file or your `.bash_functions` file.

## Usage

`crosstabcsv` reads from stdin and (currently) takes no other arguments. Below is an [example taken from the PSQL wiki](https://wiki.postgresql.org/wiki/Crosstabview) on `\crosstabview`:

```
$ cat example.csv | column -ts,
v   h   c    hsort 
v0  h4  qux  4
v1  h0  baz  1
v1  h2  foo  3
v2  h1  bar  2

$ cat example.csv | crosstabcsv | column -ts,
v   h0   h1   h2   h4
v1  baz       foo  
v2       bar       
v0                 qux
```

(`column` is used only to pretty-print the CSVs for legibility.)

The 4th column, for sorting the output columns, is optional.

Column names are not important, except the first, which is echoed in the output.

## Limitations

The order of the columns in the input is important -- unlike the real `\crosstabcsv`, which takes 4 arguments for columns, this simple function just takes the first 4 columns as it finds them. Subsequent columns are dropped.