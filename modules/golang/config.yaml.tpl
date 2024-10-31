_mysql: &mysql
  ro_addr: ${dbRO}
  rw_addr: ${dbRW}
  user: ${dbUser}
  password: ${dbPassword}
  database: ${dbName}
  maxIdle: 5
  maxOpen: 10

ai:
  aws:
    search:
      baseURL: ${searchBaseUrl}
      index: ${searchIndex}
      languages:
      %{ for language in jsondecode(languages) ~}
        - ${language}
      %{ endfor ~}
      username: ${searchUser}
      password: ${searchPassword}
  eyelevelSearch:
    apiKey: ${groundxServiceKey}
    baseURL: http://${rankerService}.${namespace}.svc.cluster.local
  layout:
    client:
      apiKey: ${groundxServiceKey}
      baseURL: http://${layoutService}.${namespace}.svc.cluster.local
      callbackURL: http://${layoutWebhookService}.${namespace}.svc.cluster.local
  openai:
    apiKey: ${summaryApiKey}
    baseURL: ${summaryBaseUrl}
    defaultKitId: 0
  search: eyelevel

environment: prod

groundxServer:
  baseURL: http://${groundxService}.${namespace}.svc.cluster.local
  port: 8080

init:
  mysql:
    user: root
    password: ${dbRootPassword}
  search:
    password: ${searchRootPassword}
    searchModel: all_access
    username: admin

integrationTests:
  search:
    duration: 3660
    fileId: ey-mtr6hapxq7d94zigammwir6xz4
    modelId: 1

layoutWebhookServer:
  baseURL: http://${layoutWebhookService}.${namespace}.svc.cluster.local
  port: 8080

kafka:
  fileLayoutDev:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-layout-dev
  fileLayoutProd:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-layout-prod
  filePreProcess:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-pre-process
  fileProcess:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-process
  filePostProcess:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-post-process
  fileSummaryDev:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-summary-dev
  fileSummaryProd:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-summary-prod
  fileUpdate:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-update
  fileUpload:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: file-upload
  stripeEvent:
    broker: ${streamBaseUrl}
    groupId: eyelevel-kafka
    topic: stripe-event

owner:
  baseURL: http://${groundxService}.${namespace}.svc.cluster.local/api/v1
  name: on-prem
  type: ${deploymentType}
  username: ${groundxUsername}

preProcessFileServer:
  baseURL: http://${preProcessService}.${namespace}.svc.cluster.local
  port: 8080

processFileServer:
  baseURL: http://${processService}.${namespace}.svc.cluster.local
  port: 8080

processors:
  layout: [3]
  map: [4]
  saveFile: [2]
  skipGenerate: [1]
  skipLayout: [5]
  skipMap: [6]
  skipSummarize: [7]
  summarize: [8]
  summarizeChunks: [10]
  summarizeSections: [9]

queueFileServer:
  baseURL: http://${queueService}.${namespace}.svc.cluster.local
  pollTime: 1
  port: 8080

rec:
  mysql: *mysql
  session:
    addr: ${cacheAddr}:${cachePort}
    notCluster: ${cacheNotCluster}

ssp:
  baseURL: http://${dashboardService}.${namespace}.svc.cluster.local
  dashboardURL: http://${dashboardService}.${namespace}.svc.cluster.local

summaryServer:
  baseURL: http://${summaryService}.${namespace}.svc.cluster.local
  maxConcurrent: ${summaryClientThreads}
  port: 8080

upload:
  baseDomain: ${fileBaseDomain}
  baseUrl: ${fileSSL ? "https" : "http"}://${fileBaseDomain}
  bucket: ${uploadBucket}
  bucketUrl: ${fileSSL ? "https" : "http"}://${fileBaseDomain}
  id: ${fileUsername}
  secret: ${filePassword}
  service: minio
  ssl: ${fileSSL}

uploadFileServer:
  baseURL: http://${uploadService}.${namespace}.svc.cluster.local
  port: 8080