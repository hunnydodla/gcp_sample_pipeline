from setuptools import setup, find_packages

setup(
    name='gcp-dataflow-pipeline',
    version='0.1',
    packages=find_packages(),  # This captures parse_transforms/
    install_requires=[
        'apache-beam[gcp]'
    ],
    include_package_data=True,
    zip_safe=False
)