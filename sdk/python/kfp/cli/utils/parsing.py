# Copyright 2022 The Kubeflow Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import re
from typing import Callable


def get_param_descr(fn: Callable, param_name: str) -> str:
    """Extracts the description of a parameter from the docstring of a function
    or method. Docstring must conform to Google Style (https://sphinxcontrib-
    napoleon.readthedocs.io/en/latest/example_google.html).

    Args:
        fn (Callable): The function of method with a __doc__ docstring implemented.
        param_name (str): The parameter for which to extract the description.

    Returns:
        str: The description of the parameter.
    """
    docstring = fn.__doc__

    if docstring is None:
        raise ValueError(
            f'Could not find parameter {param_name} in docstring of {fn}')
    lines = docstring.splitlines()

    # Find Args section
    for i, line in enumerate(lines):
        if line.lstrip().startswith('Args:'):
            break
    else:  # No Args section found
        raise ValueError(f'No Args section found in docstring of {fn}')

    lines = lines[i + 1:]
    # More lenient regex pattern
    first_line_args_regex = rf'^\s*{param_name}\s*(?:\([^)]*\))?\s*:\s*'
    first_already_found = False
    return_lines = []
    for line in lines:
        stripped = line.lstrip()
        print(f"Checking line: '''{line}'''")
        print(f"Stripped line: '''{stripped}'''")
        print(f"Regex match: {bool(re.match(first_line_args_regex, stripped))}")
    raise ValueError(
        f'Could not find parameter {param_name} in docstring of {fn}')