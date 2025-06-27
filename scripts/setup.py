from setuptools import setup, find_packages

setup(
    name='customer_dataflow',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'apache-beam[gcp]'
    ],
    zip_safe=True
)