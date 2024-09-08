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
      baseURL: https://${searchService}.${namespace}.svc.cluster.local
      index: ${searchIndex}
      username: ${searchUser}
      password: ${searchPassword}
  eyelevelSearch:
    apiKey: ${groundxServiceKey}
    baseURL: https://${rankerService}.${namespace}.svc.cluster.local
  layout:
    client:
      apiKey: ${groundxServiceKey}
      baseURL: https://${layoutService}.${namespace}.svc.cluster.local
      callbackURL: https://${layoutWebhookService}.${namespace}.svc.cluster.local
  openai:
    defaultKitId: 1
  search: eyelevel

environment: prod

groundxServer:
  baseURL: https://${groundxService}.${namespace}.svc.cluster.local
  port: 8080

initMySQL:
  rw_addr: ${dbService}.${namespace}.svc.cluster.local
  user: root
  password: ${dbRootPassword}

integrationTests:
  search:
    duration: 3660
    modelId: 10000000001

layoutWebhookServer:
  baseURL: https://${layoutWebhookService}.${namespace}.svc.cluster.local
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
  baseURL: https://${groundxService}.${namespace}.svc.cluster.local/api/v1
  username: ${groundxUsername}

preProcessFileServer:
  baseURL: https://${preProcessService}.${namespace}.svc.cluster.local
  port: 8080

processFileServer:
  baseURL: https://${processService}.${namespace}.svc.cluster.local
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
  summarizeChunks: [9]
  summarizeSections: [10]

queueFileServer:
  baseURL: https://${queueService}.${namespace}.svc.cluster.local
  port: 8080

rec:
  mysql: *mysql
  session:
    addr: ${cacheService}.${namespace}.svc.cluster.local:6379
    notCluster: ${cacheNotCluster}

ssp:
  baseURL: https://${dashboardService}.${namespace}.svc.cluster.local
  dashboardURL: https://${dashboardService}.${namespace}.svc.cluster.local

summaryServer:
  baseURL: https://${summaryService}.${namespace}.svc.cluster.local
  port: 8080

upload:
  baseDomain: ${fileAccessKey}
  baseURL: https://${fileService}.${namespace}.svc.cluster.local
  bucketUrl: https://${fileService}.${namespace}.svc.cluster.local
  region: ${fileAccessSecret}

uploadFileServer:
  baseURL: https://${uploadService}.${namespace}.svc.cluster.local
  port: 8080