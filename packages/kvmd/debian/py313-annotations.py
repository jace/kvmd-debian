#!/usr/bin/python3
# Add "from __future__ import annotations" to every module under the given directory.
# kvmd targets Python 3.14, which evaluates annotations lazily (PEP 649), and some modules annotate
# with names imported only under typing.TYPE_CHECKING or defined later. On Debian's Python 3.13 that
# raises NameError at import; postponed evaluation (PEP 563) restores 3.14's behaviour. kvmd never
# inspects annotations at run time. Drop this step once Debian's default Python is 3.14.
import ast
import pathlib
import sys

FUTURE = "from __future__ import annotations\n"
changed = 0
for path in sorted(pathlib.Path(sys.argv[1]).rglob("*.py")):
    text = path.read_text()
    tree = ast.parse(text)
    if any(isinstance(n, ast.ImportFrom) and n.module == "__future__"
           and any(a.name == "annotations" for a in n.names) for n in tree.body):
        continue
    if not tree.body:
        continue
    first = tree.body[0]
    has_doc = isinstance(first, ast.Expr) and isinstance(getattr(first, "value", None), ast.Constant) \
        and isinstance(first.value.value, str)
    lines = text.splitlines(keepends=True)
    # insert after the docstring, or before the first statement (keeping the licence comment on top)
    at = first.end_lineno if has_doc else first.lineno - 1
    lines.insert(at, FUTURE)
    path.write_text("".join(lines))
    changed += 1
print(f"py313-annotations: {changed} modules")
