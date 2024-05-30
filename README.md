<!-- Header block for project -->
<hr>

<div align="center">

![logo](https://user-images.githubusercontent.com/3129134/163255685-857aa780-880f-4c09-b08c-4b53bf4af54d.png)

<h1 align="center">Unity Initiator</h1>
<!-- ☝️ Replace with your repo name ☝️ -->

</div>

<pre align="center">A framework for implementing triggers and evaluators in the Unity SDS</pre>
<!-- ☝️ Replace with a single sentence describing the purpose of your repo / proj ☝️ -->

<!-- Header block for project -->

[![Python package](https://github.com/unity-sds/unity-initiator/actions/workflows/python-package.yml/badge.svg)](https://github.com/unity-sds/unity-initiator/actions/workflows/python-package.yml)

![initiators_diagram](https://github.com/unity-sds/unity-initiator/assets/387300/a698a19d-7204-486f-a942-7c9b6f789cb1)
<!-- ☝️ Screenshot of your software (if applicable) via ![](https://uri-to-your-screenshot) ☝️ -->

### What is Unity SDS?
Quite simply, an SDS (Science Data System) is an orchestrated set of networked compute and storage resources that is adapted to process data through a pipeline. As described by [Hua et al. [2022]](#1):
> Science Data Systems (SDSes) provide the capability to develop, test, process, and analyze instrument observational data efficiently, systematically, and at large scales. SDSes ingest the raw satellite instrument observations and process them from low‐level instrument values into higher level observational measurement values that compose the science data products.

The [Unity SDS](https://github.com/unity-sds) is an implementation of an SDS by the Unity project at NASA Jet Propulsion Laboratory.

### What are triggers?
Trigger events are events that could potentially kick off processing in an SDS. Examples of trigger events are:

1. A raw data file is deposited into a location e.g. S3 bucket, local directory, etc.
1. A scheduled task runs and finds a new raw data file has been published to a data repository e.g. CMR (Common Metadata Repository), DAAC, etc.

The different types of trigger events lend themselves to particular trigger implementations. Taking #1 as an example and specifically using the S3 bucket use case, an implementation of that trigger could be to use the native S3 event notification capability to notify the SDS that a new file was deposited in the bucket. For the local directory use case, the trigger implementation could be to use the python [watchdog library](https://pypi.org/project/watchdog/) to monitor a local directory and to notify the SDS when a new file has been deposited there.

Taking #2 as an example, an implementation of that trigger would be a cron job running on a local machine that would start up a script that queries for new data using some remote API call which would then notify the SDS. An "all-in" cloud implementation of this trigger would be to use AWS EventBridge as the cron scheduler and AWS Lambda as the "script" that does the querying and SDS notification.

These are just a small subset of the different types of trigger events and their respective trigger implementations. This unity-initiator github repository provides [examples](terraform-unity/triggers) of some of these trigger implementations. More importantly, however, the unity-initator provides the common interface to which any trigger implementation can notify the SDS of a triggering event. This common interface is called the initiator topic (implemented as an SNS topic) and the following screenshot from the above architecture diagram shows their interaction:

![triggers](https://github.com/unity-sds/unity-initiator/assets/387300/f7d26a4e-908d-4b0b-913b-4e7704a8a2a1)

Trigger events by themselves don't automatically mean that SDS processing is ready to proceed. That's what evaluators are for.

### What are evaluators?


###
<!-- ☝️ Replace with a more detailed description of your repository, including why it was made and whom its intended for.  ☝️ -->

[INSERT LIST OF IMPORTANT PROJECT / REPO LINKS HERE]
<!-- example links>
[Website](INSERT WEBSITE LINK HERE) | [Docs/Wiki](INSERT DOCS/WIKI SITE LINK HERE) | [Discussion Board](INSERT DISCUSSION BOARD LINK HERE) | [Issue Tracker](INSERT ISSUE TRACKER LINK HERE)
-->

## Features

* [INSERT LIST OF FEATURES IMPORTANT TO YOUR USERS HERE]

<!-- ☝️ Replace with a bullet-point list of your features ☝️ -->

## Contents

* [Quick Start](#quick-start)
* [Changelog](#changelog)
* [FAQ](#frequently-asked-questions-faq)
* [Contributing Guide](#contributing)
* [License](#license)
* [Support](#support)

## Quick Start

This guide provides a quick way to get started with our project. Please see our [docs]([INSERT LINK TO DOCS SITE / WIKI HERE]) for a more comprehensive overview.

### Requirements

* python 3.9+
* docker
* hatch
* all other dependencies (defined in the [pyproject.toml](pyproject.toml)) will be installed and managed by hatch

<!-- ☝️ Replace with a numbered list of your requirements, including hardware if applicable ☝️ -->

### Setup Instructions for Development

1. Clone repo:
   ```
   git clone https://github.com/unity-sds/unity-initiator.git
   ```
1. Install hatch:
   ```
   pip install hatch
   ```
1. Build virtualenv and install dependencies:
   ```
   cd unity-initiator
   hatch env create
   ```
1. Install dev tools:
   ```
   ./scripts/install_dev_tools.sh
   ```
1. Test pre-commit run:
   ```
   pre-commit run --all-files
   ```
   You should see the following output:
   ```
   check for merge conflicts...............................................................Passed
   check for broken symlinks...........................................(no files to check)Skipped
   trim trailing whitespace................................................................Passed
   isort...................................................................................Passed
   black...................................................................................Passed
   ruff....................................................................................Passed
   bandit..................................................................................Passed
   prospector..............................................................................Passed
   Terraform fmt...........................................................................Passed
   Terraform docs..........................................................................Passed
   Terraform validate......................................................................Passed
   Lock terraform provider versions........................................................Passed
   Terraform validate with tflint..........................................................Passed
   Terraform validate with tfsec (deprecated, use "terraform_trivy").......................Passed
   ```

<!-- ☝️ Replace with a numbered list of how to set up your software prior to running ☝️ -->

### Build Instructions

1. Follow [Setup Instructions for Development](#setup-instructions-for-development) above.
1. Enter environment:
   ```
   hatch shell
   ```
1. Build:
   ```
   hatch build
   ```
   Wheel and tarballs will be built in the `dist/` directory:
   ```
   $ tree dist
   dist
   ├── unity_initiator-0.0.1-py3-none-any.whl
   └── unity_initiator-0.0.1.tar.gz

   1 directory, 2 files
   ```

<!-- ☝️ Replace with a numbered list of your build instructions, including expected results / outputs with optional screenshots ☝️ -->

### Test Instructions

1. Follow [Setup Instructions for Development](#setup-instructions-for-development) above.
1. Enter environment:
   ```
   hatch shell
   ```
1. Run tests:
   ```
   hatch run pytest
   ```
   For more information during test runs, set the log level accordingly. For example:
   ```
   hatch run pytest -s -v --log-cli-level=INFO --log-level=INFO
   ```

<!-- ☝️ Replace with a numbered list of your test instructions, including expected results / outputs with optional screenshots ☝️ -->

### Run Instructions

1. [INSERT STEP-BY-STEP RUN INSTRUCTIONS HERE, WITH OPTIONAL SCREENSHOTS]

<!-- ☝️ Replace with a numbered list of your run instructions, including expected results ☝️ -->

### Usage Examples

* [INSERT LIST OF COMMON USAGE EXAMPLES HERE, WITH OPTIONAL SCREENSHOTS]

<!-- ☝️ Replace with a list of your usage examples, including screenshots if possible, and link to external documentation for details ☝️ -->

## Changelog

See our [CHANGELOG.md](CHANGELOG.md) for a history of our changes.

See our [releases page]([INSERT LINK TO YOUR RELEASES PAGE]) for our key versioned releases.

<!-- ☝️ Replace with links to your changelog and releases page ☝️ -->

## Frequently Asked Questions (FAQ)

[INSERT LINK TO FAQ PAGE OR PROVIDE FAQ INLINE HERE]
<!-- example link to FAQ PAGE>
Questions about our project? Please see our: [FAQ]([INSERT LINK TO FAQ / DISCUSSION BOARD])
-->

<!-- example FAQ inline format>
1. Question 1
   - Answer to question 1
2. Question 2
   - Answer to question 2
-->

<!-- example FAQ inline with no questions yet>
No questions yet. Propose a question to be added here by reaching out to our contributors! See support section below.
-->

<!-- ☝️ Replace with a list of frequently asked questions from your project, or post a link to your FAQ on a discussion board ☝️ -->

## Contributing

[INSERT LINK TO CONTRIBUTING GUIDE OR FILL INLINE HERE]
<!-- example link to CONTRIBUTING.md>
Interested in contributing to our project? Please see our: [CONTRIBUTING.md](CONTRIBUTING.md)
-->

<!-- example inline contributing guide>
1. Create an GitHub issue ticket describing what changes you need (e.g. issue-1)
2. [Fork](INSERT LINK TO YOUR REPO FORK PAGE HERE, e.g. https://github.com/my_org/my_repo/fork) this repo
3. Make your modifications in your own fork
4. Make a pull-request in this repo with the code in your fork and tag the repo owner / largest contributor as a reviewer

**Working on your first pull request?** See guide: [How to Contribute to an Open Source Project on GitHub](https://kcd.im/pull-request)
-->

[INSERT LINK TO YOUR CODE_OF_CONDUCT.md OR SHARE TEXT HERE]
<!-- example link to CODE_OF_CONDUCT.md>
For guidance on how to interact with our team, please see our code of conduct located at: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
-->

<!-- ☝️ Replace with a text describing how people may contribute to your project, or link to your contribution guide directly ☝️ -->

[INSERT LINK TO YOUR GOVERNANCE.md OR SHARE TEXT HERE]
<!-- example link to GOVERNANCE.md>
For guidance on our governance approach, including decision-making process and our various roles, please see our governance model at: [GOVERNANCE.md](GOVERNANCE.md)
-->

## License

See our: [LICENSE](LICENSE)
<!-- ☝️ Replace with the text of your copyright and license, or directly link to your license file ☝️ -->

## Support

[INSERT CONTACT INFORMATION OR PROFILE LINKS TO MAINTAINERS AMONG COMMITTER LIST]

<!-- example list of contacts>
Key points of contact are: [@github-user-1](link to github profile) [@github-user-2](link to github profile)
-->

<!-- ☝️ Replace with the key individuals who should be contacted for questions ☝️ -->

# unity-initiator

[![PyPI - Version](https://img.shields.io/pypi/v/unity-initiator.svg)](https://pypi.org/project/unity-initiator)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/unity-initiator.svg)](https://pypi.org/project/unity-initiator)

-----

**Table of Contents**

- [Installation](#installation)
- [License](#license)

## Installation

```console
pip install unity-initiator
```

## License

`unity-initiator` is distributed under the terms of the [MIT](https://spdx.org/licenses/MIT.html) license.o

## References
<a id="1">[1]</a>
Hua, H., Manipon, G. and Shah, S. (2022).
Scaling Big Earth Science Data Systems Via Cloud Computing.
In Big Data Analytics in Earth, Atmospheric, and Ocean Sciences (eds T. Huang, T.C. Vance and C. Lynnes).
https://doi.org/10.1002/9781119467557.ch3
