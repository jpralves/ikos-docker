# Docker image for ikos

This project aims to provide a simple Docker image to encapsulate and run an [ikos](https://github.com/NASA-SW-VnV/ikos) analysis through Docker.

### Run ikos

Assuming current directory contains the source code to analyze, simply run the following command:
```Dockerfile
docker run --rm -v ${PWD}:/src jpralvesatdocker/ikos:3.4 ikos file.c > report.txt
```
If report is too big:
```Dockerfile
docker run --rm -v ${PWD}:/src jpralvesatdocker/ikos:3.4 ikos-report output.db > report.txt
```

### Building image

This image is based on fedora:41.
It uses clang and llvm from fedora 36 because of clang 14 requirement.

This image also includes patch for Python 3.13 issue. [See PR for more details](https://github.com/NASA-SW-VnV/ikos/pull/293)

### How to contribute
If it is something regarding the docker image itself you can fork and do a PR. If it is related to IKOS funcionality please open a PR in the [ikos](https://github.com/NASA-SW-VnV/ikos) repo.

It is required to explain inside the issue the steps required to reproduce the issue.

### License

Licensed under the [GNU General Public License, Version 3.0](https://www.gnu.org/licenses/gpl.txt)
