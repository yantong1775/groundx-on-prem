env = dict(
    deviceType="${deviceType}",
    searchBroker="redis://${cacheService}.${namespace}.svc.cluster.local:6379/0",
    searchCache="${cacheService}.${namespace}.svc.cluster.local",
    searchResultBroker="redis://${cacheService}.${namespace}.svc.cluster.local:6379/0",
    searchLog="${rankerService}",
    searchMaxBatchSize=${rankerMaxBatch},
    searchMaxPromptLength=${rankerMaxPrompt},
    searchModelName="${rankerModelName}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
