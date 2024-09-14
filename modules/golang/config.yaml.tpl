_mysql: &mysql
  ro_addr: ${dbService}.${namespace}.svc.cluster.local
  rw_addr: ${dbService}.${namespace}.svc.cluster.local
  user: ${dbUser}
  password: ${dbPassword}
  database: ${dbName}
  maxIdle: 5
  maxOpen: 10

ai:
  aws:
    search:
      baseURL: https://${searchService}.${namespace}.svc.cluster.local:9200
      index: ${searchIndex}
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
    modelId: 10000000001

layoutWebhookServer:
  baseURL: http://${layoutWebhookService}.${namespace}.svc.cluster.local
  port: 8080

kafka:
  fileLayoutDev:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-layout-dev
  fileLayoutProd:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-layout-prod
  filePreProcess:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-pre-process
  fileProcess:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-process
  filePostProcess:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-post-process
  fileSummaryDev:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-summary-dev
  fileSummaryProd:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-summary-prod
  fileUpdate:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-update
  fileUpload:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
    groupId: eyelevel-kafka
    topic: file-upload
  stripeEvent:
    brokers:
      - ${streamService}-cluster-cluster-kafka-bootstrap.${namespace}.svc.cluster.local:9092
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
  port: 8080

rec:
  mysql: *mysql
  session:
    addr: ${cacheService}.${namespace}.svc.cluster.local:6379
    notCluster: ${cacheNotCluster}

ssp:
  baseURL: http://${dashboardService}.${namespace}.svc.cluster.local
  dashboardURL: http://${dashboardService}.${namespace}.svc.cluster.local

summaryServer:
  baseURL: http://${summaryService}.${namespace}.svc.cluster.local
  port: 8080

upload:
  baseDomain: ${fileAccessKey}
  baseUrl: http://${fileService}.${namespace}.svc.cluster.local
  bucketUrl: http://${fileService}.${namespace}.svc.cluster.local
  region: ${fileAccessSecret}
  ssl: ${fileSSL}

uploadFileServer:
  baseURL: http://${uploadService}.${namespace}.svc.cluster.local
  port: 8080