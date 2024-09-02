_mysql: &mysql
  ro_addr: ${mysqlROAddr}
  rw_addr: ${mysqlRWAddr}
  user: ${mysqlUser}
  password: ${mysqlPassword}
  database: ${mysqlDB}
  maxIdle: 5
  maxOpen: 10

ai:
  aws:
    search:
      baseURL: https://${searchService}.${namespace}.svc.cluster.local
      index: ${searchIndex}
      username: ${searchUsername}
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
    groupId: 
    topic: 
  fileLayoutProd:
    brokers:
    groupId: 
    topic: 
  filePreProcess:
    brokers:
    groupId: 
    topic: 
  fileProcess:
    brokers:
    groupId: 
    topic: 
  filePostProcess:
    brokers:
    groupId: 
    topic: 
  fileSummaryDev:
    brokers:
    groupId: 
    topic: 
  fileSummaryProd:
    brokers:
    groupId: 
    topic: 
  fileUpdate:
    brokers:
    groupId: 
    topic: 
  fileUpload:
    brokers:
    groupId: 
    topic: 
  stripeEvent:
    brokers:
    groupId: 
    topic: 

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
    addr: ${cacheService}.${namespace}.svc.cluster.local
    notCluster: ${notCluster}

ssp:
  baseURL: https://devssp.eyelevel.ai
  dashboardURL: https://devdashboard.eyelevel.ai

summaryServer:
  baseURL: https://${summaryService}.${namespace}.svc.cluster.local
  port: 8080

upload:
  baseDomain: ${namespace}.svc.cluster.local
  baseURL: https://${fileService}.${namespace}.svc.cluster.local
  bucketUrl: https://${fileService}.${namespace}.svc.cluster.local

uploadFileServer:
  baseURL: https://${uploadService}.${namespace}.svc.cluster.local
  port: 8080