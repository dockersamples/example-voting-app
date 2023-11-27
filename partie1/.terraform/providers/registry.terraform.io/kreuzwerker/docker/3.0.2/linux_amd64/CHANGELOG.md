
<a name="v3.0.2"></a>
## [v3.0.2](https://github.com/kreuzwerker/terraform-provider-docker/compare/v3.0.1...v3.0.2) (2023-03-17)

### Docs

* correct spelling of "networks_advanced" ([#517](https://github.com/kreuzwerker/terraform-provider-docker/issues/517))

### Fix

* Implement proxy support. ([#529](https://github.com/kreuzwerker/terraform-provider-docker/issues/529))


<a name="v3.0.1"></a>
## [v3.0.1](https://github.com/kreuzwerker/terraform-provider-docker/compare/v3.0.0...v3.0.1) (2023-01-13)

### Chore

* Prepare release v3.0.1

### Fix

* Access health of container correctly. ([#506](https://github.com/kreuzwerker/terraform-provider-docker/issues/506))


<a name="v3.0.0"></a>
## [v3.0.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.25.0...v3.0.0) (2023-01-13)

### Chore

* Prepare release v3.0.0

### Docs

* Update documentation.
* Add migration guide and update README ([#502](https://github.com/kreuzwerker/terraform-provider-docker/issues/502))

### Feat

* Prepare v3 release ([#503](https://github.com/kreuzwerker/terraform-provider-docker/issues/503))


<a name="v2.25.0"></a>
## [v2.25.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.24.0...v2.25.0) (2023-01-05)

### Chore

* Prepare release v2.25.0

### Docs

* Add documentation of remote hosts. ([#498](https://github.com/kreuzwerker/terraform-provider-docker/issues/498))

### Feat

* Migrate build block to `docker_image` ([#501](https://github.com/kreuzwerker/terraform-provider-docker/issues/501))
* Add platform attribute to docker_image resource ([#500](https://github.com/kreuzwerker/terraform-provider-docker/issues/500))
* Add sysctl implementation to container of docker_service. ([#499](https://github.com/kreuzwerker/terraform-provider-docker/issues/499))


<a name="v2.24.0"></a>
## [v2.24.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.23.1...v2.24.0) (2022-12-23)

### Chore

* Prepare release v2.24.0

### Docs

* Fix generated website.
* Update command typo ([#487](https://github.com/kreuzwerker/terraform-provider-docker/issues/487))

### Feat

* cgroupns support ([#497](https://github.com/kreuzwerker/terraform-provider-docker/issues/497))
* Add triggers attribute to docker_registry_image ([#496](https://github.com/kreuzwerker/terraform-provider-docker/issues/496))
* Support registries with disabled auth ([#494](https://github.com/kreuzwerker/terraform-provider-docker/issues/494))
* add IPAM options block for docker networks ([#491](https://github.com/kreuzwerker/terraform-provider-docker/issues/491))

### Fix

* Pin data source specific tag test to older tag.

### Tests

* Add test for parsing auth headers.


<a name="v2.23.1"></a>
## [v2.23.1](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.23.0...v2.23.1) (2022-11-23)

### Chore

* Prepare release v2.23.1

### Fix

* Update shasum of busybox:1.35.0 tag in test.
* Handle Auth Header Scopes ([#482](https://github.com/kreuzwerker/terraform-provider-docker/issues/482))
* Set OS_ARCH from GOHOSTOS and GOHOSTARCH ([#477](https://github.com/kreuzwerker/terraform-provider-docker/issues/477))


<a name="v2.23.0"></a>
## [v2.23.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.22.0...v2.23.0) (2022-11-02)

### Chore

* Prepare release v2.23.0

### Feat

* wait container healthy state ([#467](https://github.com/kreuzwerker/terraform-provider-docker/issues/467))
* add docker logs data source ([#471](https://github.com/kreuzwerker/terraform-provider-docker/issues/471))

### Fix

* Update shasum of busybox:1.35.0 tag in test.
* Update shasum of busybox:1.35.0 tag
* Correct provider name to match the public registry ([#462](https://github.com/kreuzwerker/terraform-provider-docker/issues/462))


<a name="v2.22.0"></a>
## [v2.22.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.21.0...v2.22.0) (2022-09-20)

### Chore

* Prepare release v2.22.0

### Feat

* Configurable timeout for docker_container resource stateChangeConf ([#454](https://github.com/kreuzwerker/terraform-provider-docker/issues/454))

### Fix

* oauth authorization support for azurecr ([#451](https://github.com/kreuzwerker/terraform-provider-docker/issues/451))


<a name="v2.21.0"></a>
## [v2.21.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.20.3...v2.21.0) (2022-09-05)

### Chore

* Prepare release v2.21.0

### Docs

* Fix docker config example.

### Feat

* Add image_id attribute to docker_image resource. ([#450](https://github.com/kreuzwerker/terraform-provider-docker/issues/450))
* Update used goversion to 1.18. ([#449](https://github.com/kreuzwerker/terraform-provider-docker/issues/449))

### Fix

* Replace deprecated .latest attribute with new image_id. ([#453](https://github.com/kreuzwerker/terraform-provider-docker/issues/453))
* Remove reading part of docker_tag resource. ([#448](https://github.com/kreuzwerker/terraform-provider-docker/issues/448))
* Fix repo_digest value for DockerImageDatasource test.


<a name="v2.20.3"></a>
## [v2.20.3](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.20.2...v2.20.3) (2022-08-31)

### Chore

* Prepare release v2.20.3

### Fix

* Docker Registry Image data source use HEAD request to query image digest ([#433](https://github.com/kreuzwerker/terraform-provider-docker/issues/433))
* Adding Support for Windows Paths in Bash ([#438](https://github.com/kreuzwerker/terraform-provider-docker/issues/438))


<a name="v2.20.2"></a>
## [v2.20.2](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.20.1...v2.20.2) (2022-08-10)

### Chore

* Prepare release v2.20.2

### Fix

* Check the operating system for determining the default Docker socket ([#427](https://github.com/kreuzwerker/terraform-provider-docker/issues/427))

### Reverts

* fix(deps): update module github.com/golangci/golangci-lint to v1.48.0 ([#423](https://github.com/kreuzwerker/terraform-provider-docker/issues/423))


<a name="v2.20.1"></a>
## [v2.20.1](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.20.0...v2.20.1) (2022-08-10)

### Chore

* Prepare release v2.20.1
* Reduce time to setup AccTests ([#430](https://github.com/kreuzwerker/terraform-provider-docker/issues/430))

### Docs

* Improve docker network usage documentation [skip-ci]

### Feat

* Implement triggers attribute for docker_image. ([#425](https://github.com/kreuzwerker/terraform-provider-docker/issues/425))

### Fix

* Add ForceTrue to docker_image name attribute. ([#421](https://github.com/kreuzwerker/terraform-provider-docker/issues/421))


<a name="v2.20.0"></a>
## [v2.20.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.19.0...v2.20.0) (2022-07-28)

### Chore

* Prepare release v2.20.0
* Fix release targets in Makefile.

### Feat

* Implementation of `docker_tag` resource. ([#418](https://github.com/kreuzwerker/terraform-provider-docker/issues/418))
* Implement support for insecure registries ([#414](https://github.com/kreuzwerker/terraform-provider-docker/issues/414))


<a name="v2.19.0"></a>
## [v2.19.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.18.1...v2.19.0) (2022-07-15)

### Chore

* Prepare release v2.19.0

### Feat

* Add gpu flag to docker_container resource ([#405](https://github.com/kreuzwerker/terraform-provider-docker/issues/405))

### Fix

* Enable authentication to multiple registries again. ([#400](https://github.com/kreuzwerker/terraform-provider-docker/issues/400))
* ECR authentication ([#409](https://github.com/kreuzwerker/terraform-provider-docker/issues/409))


<a name="v2.18.1"></a>
## [v2.18.1](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.18.0...v2.18.1) (2022-07-14)

### Chore

* Prepare release v2.18.1
* Automate changelog generation [skip ci]

### Fix

* Improve searchLocalImages error handling. ([#407](https://github.com/kreuzwerker/terraform-provider-docker/issues/407))
* Throw errors when any part of docker config file handling goes wrong. ([#406](https://github.com/kreuzwerker/terraform-provider-docker/issues/406))
* Enables having a Dockerfile outside the context ([#402](https://github.com/kreuzwerker/terraform-provider-docker/issues/402))


<a name="v2.18.0"></a>
## [v2.18.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.17.0...v2.18.0) (2022-07-11)

### Chore

* prepare release v2.18.0

### Feat

* add runtime, stop_signal and stop_timeout properties to the docker_container resource ([#364](https://github.com/kreuzwerker/terraform-provider-docker/issues/364))

### Fix

* Correctly handle build files and context for docker_registry_image ([#398](https://github.com/kreuzwerker/terraform-provider-docker/issues/398))
* Switch to proper go tools mechanism to fix website-* workflows. ([#399](https://github.com/kreuzwerker/terraform-provider-docker/issues/399))
* compare relative paths when excluding, fixes kreuzwerker[#280](https://github.com/kreuzwerker/terraform-provider-docker/issues/280) ([#397](https://github.com/kreuzwerker/terraform-provider-docker/issues/397))


<a name="v2.17.0"></a>
## [v2.17.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.16.0...v2.17.0) (2022-06-23)

### Chore

* prepare release v2.17.0
* Exclude examples directory from renovate.
* remove the workflow to close stale issues and pull requests ([#371](https://github.com/kreuzwerker/terraform-provider-docker/issues/371))

### Fix

* update go package files directly on master to fix build.
* correct authentication for ghcr.io registry([#349](https://github.com/kreuzwerker/terraform-provider-docker/issues/349))


<a name="v2.16.0"></a>
## [v2.16.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.15.0...v2.16.0) (2022-01-24)

### Chore

* prepare release v2.16.0

### Docs

* fix service options ([#337](https://github.com/kreuzwerker/terraform-provider-docker/issues/337))
* update registry_image.md ([#321](https://github.com/kreuzwerker/terraform-provider-docker/issues/321))
* fix r/registry_image truncated docs ([#304](https://github.com/kreuzwerker/terraform-provider-docker/issues/304))

### Feat

* add parameter for SSH options ([#335](https://github.com/kreuzwerker/terraform-provider-docker/issues/335))

### Fix

* pass container rm flag ([#322](https://github.com/kreuzwerker/terraform-provider-docker/issues/322))
* add nil check of DriverConfig ([#315](https://github.com/kreuzwerker/terraform-provider-docker/issues/315))
* fmt of go files for go 1.17


<a name="v2.15.0"></a>
## [v2.15.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.14.0...v2.15.0) (2021-08-11)

### Chore

* prepare release v2.15.0
* re go gets terraform-plugin-docs

### Docs

* corrects authentication misspell. Closes [#264](https://github.com/kreuzwerker/terraform-provider-docker/issues/264)

### Feat

* add container storage opts ([#258](https://github.com/kreuzwerker/terraform-provider-docker/issues/258))

### Fix

* add current timestamp for file upload to container ([#259](https://github.com/kreuzwerker/terraform-provider-docker/issues/259))


<a name="v2.14.0"></a>
## [v2.14.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.13.0...v2.14.0) (2021-07-09)

### Chore

* prepare release v2.14.0

### Docs

* update to absolute path for registry image context ([#246](https://github.com/kreuzwerker/terraform-provider-docker/issues/246))
* update readme with logos and subsections ([#235](https://github.com/kreuzwerker/terraform-provider-docker/issues/235))

### Feat

* support terraform v1 ([#242](https://github.com/kreuzwerker/terraform-provider-docker/issues/242))

### Fix

* Update the URL of the docker hub registry ([#230](https://github.com/kreuzwerker/terraform-provider-docker/issues/230))


<a name="v2.13.0"></a>
## [v2.13.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.12.2...v2.13.0) (2021-06-22)

### Chore

* prepare release v2.13.0

### Docs

* fix a few typos ([#216](https://github.com/kreuzwerker/terraform-provider-docker/issues/216))
* fix typos in docker_image example usage ([#213](https://github.com/kreuzwerker/terraform-provider-docker/issues/213))


<a name="v2.12.2"></a>
## [v2.12.2](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.12.1...v2.12.2) (2021-05-26)

### Chore

* prepare release v2.12.2


<a name="v2.12.1"></a>
## [v2.12.1](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.12.0...v2.12.1) (2021-05-26)

### Chore

* update changelog for v2.12.1

### Fix

* add service host flattener with space split ([#205](https://github.com/kreuzwerker/terraform-provider-docker/issues/205))
* service state upgradeV2 for empty auth


<a name="v2.12.0"></a>
## [v2.12.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.11.0...v2.12.0) (2021-05-23)

### Chore

* update changelog for v2.12.0
* ignore dist folder
* configure actions/stale ([#157](https://github.com/kreuzwerker/terraform-provider-docker/issues/157))
* add the guide about Terraform Configuration in Bug Report ([#139](https://github.com/kreuzwerker/terraform-provider-docker/issues/139))
* bump docker dependency to v20.10.5 ([#119](https://github.com/kreuzwerker/terraform-provider-docker/issues/119))

### Ci

* run acceptance tests with multiple Terraform versions ([#129](https://github.com/kreuzwerker/terraform-provider-docker/issues/129))

### Docs

* update for v2.12.0
* add releasing steps
* format `Guide of Bug report` ([#159](https://github.com/kreuzwerker/terraform-provider-docker/issues/159))
* add an example to build an image with docker_image ([#158](https://github.com/kreuzwerker/terraform-provider-docker/issues/158))
* add a guide about writing issues to CONTRIBUTING.md ([#149](https://github.com/kreuzwerker/terraform-provider-docker/issues/149))
* fix Github repository URL in README ([#136](https://github.com/kreuzwerker/terraform-provider-docker/issues/136))

### Feat

* support darwin arm builds and golang 1.16 ([#140](https://github.com/kreuzwerker/terraform-provider-docker/issues/140))
* migrate to terraform-sdk v2 ([#102](https://github.com/kreuzwerker/terraform-provider-docker/issues/102))

### Fix

* rewriting tar header fields ([#198](https://github.com/kreuzwerker/terraform-provider-docker/issues/198))
* test spaces for windows ([#190](https://github.com/kreuzwerker/terraform-provider-docker/issues/190))
* replace for loops with StateChangeConf ([#182](https://github.com/kreuzwerker/terraform-provider-docker/issues/182))
* skip sign on compile action
* assign map to rawState when it is nil to prevent panic ([#180](https://github.com/kreuzwerker/terraform-provider-docker/issues/180))
* search local images with Docker image ID ([#151](https://github.com/kreuzwerker/terraform-provider-docker/issues/151))
* set "ForceNew: true" to labelSchema ([#152](https://github.com/kreuzwerker/terraform-provider-docker/issues/152))


<a name="v2.11.0"></a>
## [v2.11.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.10.0...v2.11.0) (2021-01-22)

### Chore

* update changelog for v2.11.0
* updates changelog for v2.10.0

### Docs

* fix legacy configuration style ([#126](https://github.com/kreuzwerker/terraform-provider-docker/issues/126))

### Feat

* add properties -it (tty and stdin_opn) to docker container


<a name="v2.10.0"></a>
## [v2.10.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.9.0...v2.10.0) (2021-01-08)

### Chore

* updates changelog for 2.10.0
* ignores testing folders
* adds separate bug and ft req templates

### Ci

* bumps to docker version 20.10.1
* pins workflows to ubuntu:20.04 image

### Docs

* add labels to arguments of docker_service ([#105](https://github.com/kreuzwerker/terraform-provider-docker/issues/105))
* cleans readme
* adds coc and contributing

### Feat

* supports Docker plugin ([#35](https://github.com/kreuzwerker/terraform-provider-docker/issues/35))
* support max replicas of Docker Service Task Spec ([#112](https://github.com/kreuzwerker/terraform-provider-docker/issues/112))
* add force_remove option to r/image ([#104](https://github.com/kreuzwerker/terraform-provider-docker/issues/104))
* add local semantic commit validation ([#99](https://github.com/kreuzwerker/terraform-provider-docker/issues/99))
* add ability to lint/check of links in documentation locally ([#98](https://github.com/kreuzwerker/terraform-provider-docker/issues/98))

### Fix

* set "latest" to tag when tag isn't specified ([#117](https://github.com/kreuzwerker/terraform-provider-docker/issues/117))
* image label for workflows
* remove all azure cps

### Pull Requests

* Merge pull request [#38](https://github.com/kreuzwerker/terraform-provider-docker/issues/38) from kreuzwerker/ci-ubuntu2004-workflow
* Merge pull request [#36](https://github.com/kreuzwerker/terraform-provider-docker/issues/36) from kreuzwerker/chore-gh-issue-tpl


<a name="v2.9.0"></a>
## [v2.9.0](https://github.com/kreuzwerker/terraform-provider-docker/compare/v2.8.0...v2.9.0) (2020-12-25)

### Chore

* updates changelog for 2.9.0
* update changelog 2.8.0 release date
* introduces golangci-lint ([#32](https://github.com/kreuzwerker/terraform-provider-docker/issues/32))
* fix changelog links

### Ci

* add gofmt's '-s' option
* remove unneeded make tasks
* fix test of website

### Doc

* devices is a block, not a boolean

### Feat

* adds support for OCI manifests ([#316](https://github.com/kreuzwerker/terraform-provider-docker/issues/316))
* adds security_opts to container config. ([#308](https://github.com/kreuzwerker/terraform-provider-docker/issues/308))
* adds support for init process injection for containers. ([#300](https://github.com/kreuzwerker/terraform-provider-docker/issues/300))

### Fix

* changing mounts requires ForceNew ([#314](https://github.com/kreuzwerker/terraform-provider-docker/issues/314))
* allow healthcheck to be computed as container can specify ([#312](https://github.com/kreuzwerker/terraform-provider-docker/issues/312))
* treat null user as a no-op ([#318](https://github.com/kreuzwerker/terraform-provider-docker/issues/318))
* workdir null behavior ([#320](https://github.com/kreuzwerker/terraform-provider-docker/issues/320))

### Style

* format with gofumpt

### Pull Requests

* Merge pull request [#33](https://github.com/kreuzwerker/terraform-provider-docker/issues/33) from brandonros/patch-1
* Merge pull request [#11](https://github.com/kreuzwerker/terraform-provider-docker/issues/11) from suzuki-shunsuke/format-with-gofumpt
* Merge pull request [#26](https://github.com/kreuzwerker/terraform-provider-docker/issues/26) from kreuzwerker/ci/fix-website-ci
* Merge pull request [#8](https://github.com/kreuzwerker/terraform-provider-docker/issues/8) from dubo-dubon-duponey/patch1


<a name="v2.8.0"></a>
## v2.8.0 (2020-11-11)

### Chore

* updates changelog for 2.8.0
* removes travis.yml
* deactivates travis
* removes vendor dir ([#298](https://github.com/kreuzwerker/terraform-provider-docker/issues/298))
* bump go 115 ([#297](https://github.com/kreuzwerker/terraform-provider-docker/issues/297))
* documentation updates ([#286](https://github.com/kreuzwerker/terraform-provider-docker/issues/286))
* updates link syntax ([#287](https://github.com/kreuzwerker/terraform-provider-docker/issues/287))
* fix typo ([#292](https://github.com/kreuzwerker/terraform-provider-docker/issues/292))

### Ci

* reactivats all workflows
* fix website
* only run website workflow
* exports gopath manually
* fix absolute gopath for website
* make website check separate workflow
* fix workflow names
* adds website test to unit test
* adds acc test
* adds compile
* adds go version and goproxy env
* enables unit tests for master branch
* adds unit test workflow
* adds goreleaser and gh action
* bumps docker and ubuntu versions ([#241](https://github.com/kreuzwerker/terraform-provider-docker/issues/241))
* removes debug option from acc tests
* skips test which is flaky only on travis

### Deps

* github.com/hashicorp/terraform[@sdk](https://github.com/sdk)-v0.11-with-go-modules Updated via: go get github.com/hashicorp/terraform[@sdk](https://github.com/sdk)-v0.11-with-go-modules and go mod tidy
* use go modules for dep mgmt run go mod tidy remove govendor from makefile and travis config set appropriate env vars for go modules

### Docker

* improve validation of runtime constraints

### Docs

* update container.html.markdown ([#278](https://github.com/kreuzwerker/terraform-provider-docker/issues/278))
* update service.html.markdown ([#281](https://github.com/kreuzwerker/terraform-provider-docker/issues/281))
* update restart_policy for service. Closes [#228](https://github.com/kreuzwerker/terraform-provider-docker/issues/228)
* adds new label structure. Closes [#214](https://github.com/kreuzwerker/terraform-provider-docker/issues/214)
* update anchors with -1 suffix ([#178](https://github.com/kreuzwerker/terraform-provider-docker/issues/178))
* Fix misspelled words
* Fix exported attribute name in docker_registry_image
* Fix example for docker_registry_image ([#8308](https://github.com/kreuzwerker/terraform-provider-docker/issues/8308))
* provider/docker - network settings attrs

### Feat

* conditionally adding port binding ([#293](https://github.com/kreuzwerker/terraform-provider-docker/issues/293)).
* adds docker Image build feature ([#283](https://github.com/kreuzwerker/terraform-provider-docker/issues/283))
* adds complete support for Docker credential helpers ([#253](https://github.com/kreuzwerker/terraform-provider-docker/issues/253))
* Expose IPv6 properties as attributes
* allow use of source file instead of content / content_base64 ([#240](https://github.com/kreuzwerker/terraform-provider-docker/issues/240))
* supports to update docker_container ([#236](https://github.com/kreuzwerker/terraform-provider-docker/issues/236))
* support to import some docker_container's attributes ([#234](https://github.com/kreuzwerker/terraform-provider-docker/issues/234))
* adds config file content as plain string ([#232](https://github.com/kreuzwerker/terraform-provider-docker/issues/232))
* make UID, GID, & mode for secrets and configs configurable ([#231](https://github.com/kreuzwerker/terraform-provider-docker/issues/231))
* adds import for resources ([#196](https://github.com/kreuzwerker/terraform-provider-docker/issues/196))
* add container ipc mode. ([#182](https://github.com/kreuzwerker/terraform-provider-docker/issues/182))
* adds container working dir ([#181](https://github.com/kreuzwerker/terraform-provider-docker/issues/181))

### Fix

* ignores 'remove_volumes' on container import
* duplicated buildImage function
* port objects with the same internal port but different protocol trigger recreation of container ([#274](https://github.com/kreuzwerker/terraform-provider-docker/issues/274))
* panic to migrate schema of docker_container from v1 to v2 ([#271](https://github.com/kreuzwerker/terraform-provider-docker/issues/271)). Closes [#264](https://github.com/kreuzwerker/terraform-provider-docker/issues/264)
* pins docker registry for tests to v2.7.0
* prevent force recreate of container about some attributes ([#269](https://github.com/kreuzwerker/terraform-provider-docker/issues/269))
* service endpoint spec flattening
* corrects IPAM config read on the data provider ([#229](https://github.com/kreuzwerker/terraform-provider-docker/issues/229))
* replica to 0 in current schema. Closes [#221](https://github.com/kreuzwerker/terraform-provider-docker/issues/221)
* label for network and volume after improt
* binary upload as base 64 content ([#194](https://github.com/kreuzwerker/terraform-provider-docker/issues/194))
* service env truncation for multiple delimiters ([#193](https://github.com/kreuzwerker/terraform-provider-docker/issues/193))
* destroy_grace_seconds are considered ([#179](https://github.com/kreuzwerker/terraform-provider-docker/issues/179))

### Make

* Add website + website-test targets

### Provider

* Ensured Go 1.11 in TravisCI and README provider: Run go fix provider: Run go fmt provider: Encode go version 1.11.5 to .go-version file
* Require Go 1.11 in TravisCI and README provider: Run go fix provider: Run go fmt

### Tests

* Skip test if swap limit isn't available ([#136](https://github.com/kreuzwerker/terraform-provider-docker/issues/136))
* Simplify Dockerfile(s)

### Vendor

* github.com/hashicorp/terraform/...[@v0](https://github.com/v0).10.0
* Ignore github.com/hashicorp/terraform/backend

### Website

* Docs sweep for lists & maps
* note on docker
* docker docs

### Pull Requests

* Merge pull request [#134](https://github.com/kreuzwerker/terraform-provider-docker/issues/134) from terraform-providers/go-modules-2019-03-01
* Merge pull request [#135](https://github.com/kreuzwerker/terraform-provider-docker/issues/135) from terraform-providers/t-simplify-dockerfile
* Merge pull request [#47](https://github.com/kreuzwerker/terraform-provider-docker/issues/47) from captn3m0/docker-link-warning
* Merge pull request [#60](https://github.com/kreuzwerker/terraform-provider-docker/issues/60) from terraform-providers/f-make-website
* Merge pull request [#23](https://github.com/kreuzwerker/terraform-provider-docker/issues/23) from JamesLaverack/patch-1
* Merge pull request [#18](https://github.com/kreuzwerker/terraform-provider-docker/issues/18) from terraform-providers/vendor-tf-0.10
* Merge pull request [#5046](https://github.com/kreuzwerker/terraform-provider-docker/issues/5046) from tpounds/use-built-in-schema-string-hash
* Merge pull request [#3761](https://github.com/kreuzwerker/terraform-provider-docker/issues/3761) from ryane/f-provider-docker-improvements
* Merge pull request [#3383](https://github.com/kreuzwerker/terraform-provider-docker/issues/3383) from apparentlymart/docker-container-command-docs
* Merge pull request [#1564](https://github.com/kreuzwerker/terraform-provider-docker/issues/1564) from nickryand/docker_links

