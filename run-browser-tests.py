#!/usr/bin/env python3

import json
from os import listdir, environ
from os.path import isfile, join, abspath
import webbrowser

test_cases = []

for f in listdir("tests"):
    if f.endswith(".wgsl"):
        with open(f'tests/{f}','r') as file:
            source = file.read().strip();
        expected_filename = f.replace('.wgsl', '.expected')
        with open(f'tests/{expected_filename}','r') as file:
            expected = file.read().strip();
        test_cases.append({
            "name": f,
            "source": source,
            "expected": expected
        })

test_cases_json = json.dumps(test_cases)

with open(f'template.html','rt') as file:
    template = file.read().strip();

test_html = template.replace('__TESTCASES__', test_cases_json);

with open(f'test.html','wt') as file:
    file.write(test_html)

test_html_path = abspath("test.html")
print(test_html_path)
if "DONTOPEN" not in environ:
    webbrowser.open('file://' + test_html_path, new=True)

