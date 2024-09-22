env = dict(
    deviceType="${deviceType}",
    summaryBroker="redis://${cacheService}.${namespace}.svc.cluster.local:6379/0",
    summaryCache="${cacheService}.${namespace}.svc.cluster.local",
    summaryResultBroker="redis://${cacheService}.${namespace}.svc.cluster.local:6379/0",
    summaryLog="${summaryService}",
    summaryMaxBatchSize=${summaryMaxBatch},
    summaryMaxPromptLength=${summaryMaxPrompt},
    summaryModelName="${summaryModelName}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
