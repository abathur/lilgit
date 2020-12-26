"""Configure doxy_db."""

from setuptools import setup

with open("README.md", "r") as f:
    readme = f.read()

setup(
    name="lilgit",
    author="Travis A. Everett",
    author_email="travis.a.everett+lilgit@gmail.com",
    install_requires=["pygit2"],
    # setup_requires=["pytest-runner"],
    # tests_require=["pytest", "coverage"],
    # extras_require={"dev": ["black"]},
    # packages=["lilgit"],
    description="A smol (quick) git status plugin",
    long_description=readme,
    include_package_data=True,
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Topic :: Utilities",
    ],
    scripts=["lilgitd"],
    license="MIT",
    keywords="git status",
    url="https://github.com/abathur/lilgit",
    project_urls={
        "Issue Tracker": "https://github.com/abathur/lilgit/issues",
        # "Documentation": "https://github.com/abathur/lilgit",
    },
    # test_suite="lilgit.tests",
)
