# concourse-webhook-resource
Leverage API calls to trigger concourse jobs programmatically and within limits

The concourse webhook resource does what the label says: it is a means of
leveraging a git repository and concourse resource to programatically set a
pipeline to fly via HTTP API call whilst allowing throttling of the freqency
at which API calls may trigger the pipeline.

The resource works by using a file in a git repository as a tracking log where
the linux epoch of every new 'version' is appended as a new line when a new
version is created. New versions are created if a check happens outside of the
configured 'limit', measured in seconds.

To use the resource simply define its minimal values as exemplified below then
make a POST call to check the resource passing the webhook_token as a query
parameter:

Example pipeline leveraging resource:
```
resource_types:
- name: webhook
  type: docker-image
  source:
    repository: ghcr.io/ardavanhashemzadeh/concourse-webhook-resource

resources:
- name: my-resource
  check_every: never
  type: webhook
  webhook_token: helloworld
  source:
    uri: git@github.com:ardavanhashemzadeh/concourse-webhook-resource.git
    branch: main
    name: pipeline
    email: pipe@line.net
    private_key: ((git-ssh-key))
    filename: testing
    limit: 300

jobs:
- name: my-job
  plan:
  - get: my-resource
    trigger: true
  - task: my-task
    config:
      platform: linux
      image_resource: { type: registry-image, source: { repository: busybox } }
      run: { path: echo, args: [ "hello world" ] }
```

Fire off the pipeline by checking resource:
```
curl -X POST 'https://CONCOURSEURL/api/v1/teams/TEAM/pipelines/PIPELINE/resources/RESOURCE/check/webhook?webhook_token=TOKEN'
```