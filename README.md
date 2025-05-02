# redhat-image-mode-actions
## Template repo for Github Actions based builds of bootc images. 
This repository is designed be used with the exercise in the redhat-cop/redhat-image-mode-demo repository. This template provides a sample Containerfile and workflow as a starting point for use in your own account. The workflow can be triggered in two ways, by creating a tag or manually. A manual trigger will set one of the tags to the branch name which may overwrite older manual builds.  For more information on the workflow design, refer to the exercise.

## Workflow variables to be aware of
In the `env` section of the [.github/workflows/build_rhel_bootc.yml](.github/workflows/build_rhel_bootc.yml) file, there are several values that can be used to influence how the build is managed. They are injected as environment variables throughout the workflow. For this GitHub template, some of these are platform variables and others are secrets defined in the repository or by the platform. We attempt to keep these variables similar across all examples, the workflow file will have comments where platform specific changes are used.

The following table describes all of the variables within the workflow:

| Variables | Description | Default Value | Customization Required |
| --------- | ----------- | ------------- | ------ |
| `SMDEV_CONTAINER_OFF` | Disables Subscription Manager within a container (Should not be modified) | `1` | No |
| `RHT_ORGID` | Red Hat Subscription Manager Organization ID |  | Yes |
| `RHT_ACT_KEY` | Red Hat Subscription Manager Activation Key |  | Yes |
| `SOURCE_REGISTRY_HOST` | Hostname of the registry containing the source image | `registry.redhat.io` | No |
| `SOURCE_REGISTRY_USER` | Username for the registry containing the base image |  | Yes |
| `SOURCE_REGISTRY_PASSWORD` | Password for the registry containing the base image |  | Yes |
| `CONTAINERFILE` | Containerfile to build | `Containerfile` | No |
| `DEST_IMAGE` | Destination image namespace and repository for the build (such as `myrepo/myimage`) | `github-user/github-repo-name` | No |
| `TAGLIST` | Space separated list of tags to include as part of the image | `latest`, short SHA of the commit, branch name | No |
| `DEST_REGISTRY_HOST` | Hostname of the registry containing the built image | `ghcr.io` | No |
| `DEST_REGISTRY_USER` | Username for the registry containing the built image | GitHub user | No |
| `DEST_REGISTRY_PASSWORD` | Password for the registry containing the built image | User access token | No |

## Using Red Hat accounts
For RHEL, this template uses an *activation key* to get access to a subscription and a *service account* to get access to the terms based registry images. These are secrets defined within the repo settings.You can easily change the names of these in the repo and the workflow file to suit your own standards.

## Accessing a subscription during build

To use packages from the RHEL repositories, the GHA runner will need to have subscription information available. This workflow will register the build container, execute the build, and then unregister as a final step. You will only be using the subscription for the duration of the build. To use `subscription-manager` in a pipieline like this, it's easiest to use an activation key. If you don't have a subscription already, the [No-cost RHEL for developers subscription](https://developers.redhat.com/products/rhel/download) is a good option.

If you aren't familiar with activation keys, from the docs:
> An activation key is a preshared authentication token that enables authorized users to register and auto-configure systems. Running a registration command with an activation key and organization  ID combination, instead of a username and password combination, increases security and facilitates automation.

[Creating an activation key in the console](https://docs.redhat.com/en/documentation/subscription_central/1-latest/html/getting_started_with_activation_keys_on_the_hybrid_cloud_console/assembly-creating-managing-activation-keys#proc-creating-act-keys-console_)

### Activation key secrets
To use this template, the following two secrets need to be created as *Actions secrets and variables* with the appropriate values:

* *RHT_ORGID* stores the Organization ID
* *RHT_ACT_KEY* stores the Activation key name

## Getting access to the base image
Unlike UBI, the bootc base image does require an account to access since this is a full RHEL host. To log into the registry during a pipeline build or other automation, you can [create a regitry service account](https://access.redhat.com/RegistryAuthentication#registry-service-accounts-for-shared-environments-4) in tne customer portal.

### Token secrets
To use this template, the following two secrets need to be created as *Actions secrets and variables* with the appropriate values:

* *SOURCE_REGISTRY_USER* stores the token username (has a "|" character in the name)
* *SOURCE_REGISTRY_PASSWORD* stores the token password

## Other resources

This repository is one example of several](https://gitlab.com/redhat/cop/rhel/rhel-image-mode-cicd) for using common Continuous Integration and Continuous Delivery tools to produce image mode for RHEL instances.