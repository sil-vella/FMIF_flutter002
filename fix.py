import os
import re

def replace_print_with_log(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)

                with open(file_path, 'r') as f:
                    content = f.read()

                # Add the alias import if log is used
                if 'print(' in content:
                    if "import 'dart:developer' as dev;" not in content:
                        # Add import at the top
                        content = re.sub(
                            r"(import .+;)",
                            r"import 'dart:developer' as dev;\n\1",
                            content,
                            count=1,
                        )

                    # Replace all instances of `print` with `dev.log`
                    content = content.replace('print(', 'dev.log(')

                    # Write changes back to the file
                    with open(file_path, 'w') as f:
                        f.write(content)
                    print(f"Updated: {file_path}")

# Run the function on the 'lib' folder
if __name__ == "__main__":
    lib_directory = os.path.join(os.getcwd(), 'lib')
    replace_print_with_log(lib_directory)
