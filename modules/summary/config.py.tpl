env = dict(
    deviceType="${deviceType}",
    summaryBroker="redis://${cacheAddr}:${cachePort}/0",
    summaryResultBroker="redis://${cacheAddr}:${cachePort}/0",
    summaryLog="${summaryService}",
    summaryMaxBatchSize=${summaryMaxBatch},
    summaryMaxPromptLength=${summaryMaxPrompt},
    summaryModelName="${summaryModelName}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
